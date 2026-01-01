import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/env/api_base_url.dart';

class AgendaModel {
  final int agendaId;
  final String judul;
  final String deskripsi;
  final String tipe;
  final DateTime tanggal;
  final String waktuMulai;
  final String waktuSelesai;
  final Map<String, dynamic>? guru;
  final Map<String, dynamic>? kelas;
  final Map<String, dynamic>? ekstrakulikuler;

  AgendaModel({
    required this.agendaId,
    required this.judul,
    required this.deskripsi,
    required this.tipe,
    required this.tanggal,
    required this.waktuMulai,
    required this.waktuSelesai,
    this.guru,
    this.kelas,
    this.ekstrakulikuler,
  });

  factory AgendaModel.fromJson(Map<String, dynamic> json) {
    return AgendaModel(
      agendaId: json['Agenda_Id'] ?? 0,
      judul: json['Judul'] ?? '',
      deskripsi: json['Deskripsi'] ?? '',
      tipe: json['Tipe'] ?? 'sekolah',
      tanggal: DateTime.parse(json['Tanggal'] ?? DateTime.now().toIso8601String()),
      waktuMulai: json['Waktu_Mulai'] ?? '08:00',
      waktuSelesai: json['Waktu_Selesai'] ?? '10:00',
      guru: json['guru'],
      kelas: json['kelas'],
      ekstrakulikuler: json['ekstrakulikuler'],
    );
  }

  String get tipeDisplay {
    switch (tipe.toLowerCase()) {
      case 'sekolah': return 'Sekolah (Umum)';
      case 'perkelas': return 'Kelas';
      case 'ekskul': return 'Ekstrakurikuler';
      default: return tipe;
    }
  }

  String get tujuanDisplay {
    switch (tipe.toLowerCase()) {
      case 'perkelas': 
        return 'Kelas - ${kelas?['Nama_Kelas'] ?? ''}';
      case 'ekskul': 
        return 'Ekskul - ${ekstrakulikuler?['nama'] ?? ''}';
      default: return 'Umum';
    }
  }

  String get waktuDisplay {
    final start = waktuMulai.length >= 5 ? waktuMulai.substring(0, 5) : waktuMulai;
    final end = waktuSelesai.length >= 5 ? waktuSelesai.substring(0, 5) : waktuSelesai;
    return '$start - $end';
  }
}

class AgendaApiService {
  static String get baseUrl => ApiConfig.baseUrl + '/api';
  
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final guruId = prefs.getInt('Guru_Id');
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (guruId != null) {
      headers['Guru_Id'] = guruId.toString();
    }
    
    return headers;
  }

  static Future<List<AgendaModel>> getAgendaGuru() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/guru/agenda'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => AgendaModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createAgenda(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/guru/agenda'),
        headers: headers,
        body: json.encode(data),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateAgenda(int id, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/guru/agenda/$id'),
        headers: headers,
        body: json.encode(data),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteAgenda(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/guru/agenda/$id'),
        headers: headers,
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getDropdownData() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/guru/agenda/dropdown-data'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Failed to load dropdown data'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}

class Agenda extends StatefulWidget {
  const Agenda({Key? key}) : super(key: key);

  @override
  State<Agenda> createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        return isMobile ? const MobileAgendaWithNav() : Scaffold(
          backgroundColor: const Color(0xFFFDFBF0),
          appBar: AppBar(
            title: const Text('Agenda', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: const Color(0xFF465940),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: Builder(builder: (context) => IconButton(
              icon: const Icon(Icons.menu), 
              onPressed: () => Scaffold.of(context).openDrawer()
            )),
          ),
          drawer: const Sidebar(),
          body: const SafeArea(child: WebAgendaContent()),
        );
      },
    );
  }
}

class MobileAgendaWithNav extends StatefulWidget {
  const MobileAgendaWithNav({super.key});

  @override
  State<MobileAgendaWithNav> createState() => _MobileAgendaWithNavState();
}

class _MobileAgendaWithNavState extends State<MobileAgendaWithNav> {
  int _currentIndex = 1; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF0),
      appBar: AppBar(
        title: const Text('Agenda', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF465940),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(builder: (context) => IconButton(
          icon: const Icon(Icons.menu), 
          onPressed: () => Scaffold.of(context).openDrawer()
        )),
      ),
      drawer: const Sidebar(),
      body: const SafeArea(child: MobileAgendaContent()),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(
            color: Colors.grey.withOpacity(0.3), 
            blurRadius: 10, 
            offset: const Offset(0, -2)
          )]
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            switch (index) {
              case 0: Navigator.pushReplacementNamed(context, '/guru/dashboard'); break;
              case 1: break; 
              case 2: Navigator.pushReplacementNamed(context, '/guru/pengumuman'); break;
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF465940),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Utama'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Agenda'),
            BottomNavigationBarItem(icon: Icon(Icons.announcement), label: 'Pengumuman'),
          ],
        ),
      ),
    );
  }
}

abstract class BaseAgendaContent extends StatefulWidget {
  const BaseAgendaContent({super.key});
}

abstract class BaseAgendaContentState<T extends BaseAgendaContent> extends State<T> {
  List<AgendaModel> _apiAgendaList = [];
  bool _showForm = false;
  AgendaModel? _editingAgenda;
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String _selectedTipe = "sekolah";
  Map<String, dynamic>? _selectedEkstrakulikuler;
  DateTime? _selectedDate;
  TimeOfDay? _selectedWaktuMulai;
  TimeOfDay? _selectedWaktuSelesai;
  Map<String, dynamic>? _kelasGuru;
  List<Map<String, dynamic>> _ekskulOptions = [];
  bool _isLoading = false;

  bool get isMobile;

  @override
  void initState() {
    super.initState();
    _loadAgendaFromApi();
    _loadDropdownDataFromApi();
    _selectedDate = DateTime.now();
    _selectedWaktuMulai = TimeOfDay.now();
    _selectedWaktuSelesai = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _loadAgendaFromApi() async {
    setState(() => _isLoading = true);
    try {
      final agenda = await AgendaApiService.getAgendaGuru();
      setState(() {
        _apiAgendaList = agenda;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Gagal memuat agenda: $e');
    }
  }

  void _loadDropdownDataFromApi() async {
    try {
      final response = await AgendaApiService.getDropdownData();
      if (response['success'] == true) {
        setState(() {
          final kelasGuruData = response['data']['kelas_guru'];
          _kelasGuru = kelasGuruData != null ? {
            'Kelas_Id': kelasGuruData['Kelas_Id'],
            'nama_kelas': kelasGuruData['nama_kelas'],
            'peran': kelasGuruData['peran'] ?? 'Guru'
          } : null;
          
          final ekskulList = response['data']['ekstrakulikuler'] as List;
          _ekskulOptions = ekskulList.map((ekskul) => {
            'Ekstrakulikuler_Id': ekskul['Ekstrakulikuler_Id'],
            'nama': ekskul['nama']
          }).toList();
        });
      }
    } catch (e) {
      _showErrorSnackbar('Error memuat data: $e');
    }
  }

  void _toggleForm() {
    setState(() {
      _showForm = !_showForm;
      if (!_showForm) _resetForm();
    });
  }

  void _resetForm() {
    _judulController.clear();
    _deskripsiController.clear();
    _selectedTipe = "sekolah";
    _selectedEkstrakulikuler = null;
    _selectedDate = DateTime.now();
    _selectedWaktuMulai = TimeOfDay.now();
    _selectedWaktuSelesai = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);
    _editingAgenda = null;
  }

  void _editAgenda(AgendaModel agenda) {
    setState(() {
      _editingAgenda = agenda;
      _judulController.text = agenda.judul;
      _deskripsiController.text = agenda.deskripsi;
      _selectedTipe = agenda.tipe;
      _selectedDate = agenda.tanggal;
      
      final waktuMulaiParts = agenda.waktuMulai.split(':');
      if (waktuMulaiParts.length >= 2) {
        _selectedWaktuMulai = TimeOfDay(hour: int.parse(waktuMulaiParts[0]), minute: int.parse(waktuMulaiParts[1]));
      }
      
      final waktuSelesaiParts = agenda.waktuSelesai.split(':');
      if (waktuSelesaiParts.length >= 2) {
        _selectedWaktuSelesai = TimeOfDay(hour: int.parse(waktuSelesaiParts[0]), minute: int.parse(waktuSelesaiParts[1]));
      }
      
      _showForm = true;
      _selectedEkstrakulikuler = null;
      
      if (_selectedTipe == "ekskul" && agenda.ekstrakulikuler != null) {
        try {
          _selectedEkstrakulikuler = _ekskulOptions.firstWhere(
            (ekskul) => ekskul['Ekstrakulikuler_Id'] == agenda.ekstrakulikuler!['Ekstrakulikuler_Id']
          );
        } catch (e) {
          _selectedEkstrakulikuler = null;
        }
      }
    });
  }

  void _deleteAgenda(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Agenda'),
        content: const Text('Apakah Anda yakin ingin menghapus agenda ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () { _deleteAgendaFromApi(id); Navigator.pop(context); },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteAgendaFromApi(int id) async {
    setState(() => _isLoading = true);
    final response = await AgendaApiService.deleteAgenda(id);
    setState(() => _isLoading = false);
    
    if (response['success'] == true) {
      _loadAgendaFromApi();
      _showSuccessSnackbar(response['message'] ?? 'Agenda berhasil dihapus');
    } else {
      _showErrorSnackbar('Gagal: ${response['message']}');
    }
  }

  void _publishAgenda() {
    if (_selectedDate == null || _selectedWaktuMulai == null || _selectedWaktuSelesai == null) {
      _showErrorSnackbar('Tanggal dan waktu harus diisi');
      return;
    }
    
    if (_judulController.text.isEmpty || _deskripsiController.text.isEmpty) {
      _showErrorSnackbar('Judul dan deskripsi harus diisi');
      return;
    }
    
    if (_selectedTipe == "perkelas" && _kelasGuru == null) {
      _showErrorSnackbar('Anda belum memiliki kelas. Hubungi admin untuk ditetapkan sebagai wali kelas.');
      return;
    }
    
    if (_selectedTipe == "ekskul") {
      if (_selectedEkstrakulikuler == null) {
        _showErrorSnackbar('Pilih ekstrakurikuler untuk agenda ekskul');
        return;
      }
      if (_kelasGuru == null) {
        _showErrorSnackbar('Anda belum memiliki kelas. Tidak dapat membuat agenda ekskul.');
        return;
      }
    }
    
    final waktuMulaiInMinutes = _selectedWaktuMulai!.hour * 60 + _selectedWaktuMulai!.minute;
    final waktuSelesaiInMinutes = _selectedWaktuSelesai!.hour * 60 + _selectedWaktuSelesai!.minute;
    
    if (waktuSelesaiInMinutes <= waktuMulaiInMinutes) {
      _showErrorSnackbar('Waktu selesai harus setelah waktu mulai');
      return;
    }

    final Map<String, dynamic> agendaData = {
      'Judul': _judulController.text,
      'Deskripsi': _deskripsiController.text,
      'Tipe': _selectedTipe,
      'Tanggal': _selectedDate!.toIso8601String().split('T')[0],
      'Waktu_Mulai': '${_selectedWaktuMulai!.hour.toString().padLeft(2, '0')}:${_selectedWaktuMulai!.minute.toString().padLeft(2, '0')}',
      'Waktu_Selesai': '${_selectedWaktuSelesai!.hour.toString().padLeft(2, '0')}:${_selectedWaktuSelesai!.minute.toString().padLeft(2, '0')}',
    };

    if (_selectedTipe == 'ekskul') {
      agendaData['Ekstrakulikuler_Id'] = _selectedEkstrakulikuler!['Ekstrakulikuler_Id'];
    }

    _publishAgendaToApi(agendaData);
  }

  void _publishAgendaToApi(Map<String, dynamic> data) async {
    setState(() => _isLoading = true);
    
    try {
      final response = _editingAgenda != null 
          ? await AgendaApiService.updateAgenda(_editingAgenda!.agendaId, data)
          : await AgendaApiService.createAgenda(data);

      setState(() => _isLoading = false);

      if (response['success'] == true) {
        _loadAgendaFromApi();
        setState(() {
          _showForm = false;
          _resetForm();
        });
        _showSuccessSnackbar(response['message'] ?? 'Agenda berhasil dipublikasikan');
      } else {
        final errorMessage = response['message'] ?? 'Terjadi kesalahan';
        final errors = response['errors'] ?? {};
        
        String detailedError = errorMessage;
        if (errors.isNotEmpty) {
          detailedError += '\n${errors.values.join('\n')}';
        }
        
        _showErrorSnackbar(detailedError);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green, duration: const Duration(seconds: 3)),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: _selectedDate ?? DateTime.now(), 
      firstDate: DateTime(2000), 
      lastDate: DateTime(2100)
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectWaktuMulai(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedWaktuMulai ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedWaktuMulai = picked);
    }
  }

  Future<void> _selectWaktuSelesai(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedWaktuSelesai ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedWaktuSelesai = picked);
    }
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
  String _getMonthName(int month) => ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][month];
  String _formatTime(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Widget buildHeaderWithAddButton();
  Widget buildAgendaList();
  Widget buildAgendaForm();
  Widget buildFormField({required TextEditingController controller, required String label, required String hint, int maxLines = 1});
  Widget buildTipeDropdown();
  Widget buildKelasInfo();
  Widget buildEkskulDropdown();
  Widget buildDateField();
  Widget buildTimeField({required String label, required TimeOfDay? selectedTime, required VoidCallback onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.all(32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (!_showForm) buildHeaderWithAddButton(),
            if (!_showForm) buildAgendaList() else buildAgendaForm(),
            SizedBox(height: isMobile ? 20 : 40),
          ]),
        ),
        if (_isLoading) Container(
          color: Colors.black54,
          child: const Center(child: CircularProgressIndicator(color: Color(0xFF465940))),
        ),
      ],
    );
  }
}

class MobileAgendaContent extends BaseAgendaContent {
  const MobileAgendaContent({super.key});

  @override
  bool get isMobile => true;

  @override
  State<MobileAgendaContent> createState() => _MobileAgendaContentState();
}

class _MobileAgendaContentState extends BaseAgendaContentState<MobileAgendaContent> {
  @override
  bool get isMobile => true;

  @override
  Widget buildHeaderWithAddButton() => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Agenda Sekolah', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 12),
      Align(alignment: Alignment.centerRight, child: ElevatedButton.icon(
        onPressed: _toggleForm,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Buat Agenda'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF465940), 
          foregroundColor: Colors.white, 
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
        ),
      )),
    ]),
  );

  @override
  Widget buildAgendaList() => _isLoading 
    ? const Center(child: CircularProgressIndicator(color: Color(0xFF465940)))
    : _apiAgendaList.isEmpty 
      ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_note_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Belum ada agenda', style: TextStyle(fontSize: 16, color: Colors.grey)),
              SizedBox(height: 8),
              Text('Tekan tombol "Buat Agenda" untuk menambahkan', 
                   style: TextStyle(fontSize: 14, color: Colors.grey), textAlign: TextAlign.center),
            ],
          ),
        )
      : Column(children: _apiAgendaList.map((agenda) => _buildAgendaCard(agenda)).toList());

  Widget _buildAgendaCard(AgendaModel agenda) => Card(
    elevation: 2,
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(agenda.judul, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F)))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF465940).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(agenda.tipeDisplay, style: TextStyle(color: const Color(0xFF465940), fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 8),
        Text('${_formatDate(agenda.tanggal)} • ${agenda.waktuDisplay}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 12),
        Text(agenda.deskripsi, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 12),
        Text('Tujuan: ${agenda.tujuanDisplay}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF465940))),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: ElevatedButton(
            onPressed: () => _editAgenda(agenda),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A9B6E), foregroundColor: Colors.white),
            child: const Text('Edit'),
          )),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(
            onPressed: () => _deleteAgenda(agenda.agendaId),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE74C3C), foregroundColor: Colors.white),
            child: const Text('Hapus'),
          )),
        ]),
      ]),
    ),
  );

  @override
  Widget buildAgendaForm() => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_editingAgenda == null ? 'Buat Agenda Baru' : 'Edit Agenda', 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 20),
        buildFormField(controller: _judulController, label: 'Judul Agenda', hint: 'Masukkan judul agenda'),
        const SizedBox(height: 16),
        buildFormField(controller: _deskripsiController, label: 'Deskripsi Agenda', hint: 'Masukkan deskripsi agenda', maxLines: 4),
        const SizedBox(height: 16),
        buildTipeDropdown(),
        const SizedBox(height: 16),
        if (_selectedTipe == "perkelas") buildKelasInfo(),
        if (_selectedTipe == "perkelas" && _kelasGuru == null) _buildNoKelasWarning(),
        if (_selectedTipe == "ekskul") buildEkskulDropdown(),
        const SizedBox(height: 16),
        buildDateField(),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: buildTimeField(label: 'Waktu Mulai', selectedTime: _selectedWaktuMulai, onTap: () => _selectWaktuMulai(context))),
          const SizedBox(width: 12),
          Expanded(child: buildTimeField(label: 'Waktu Selesai', selectedTime: _selectedWaktuSelesai, onTap: () => _selectWaktuSelesai(context))),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: ElevatedButton(
            onPressed: _toggleForm,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
            child: const Text('Batal'),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: _isLoading ? null : _publishAgenda,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF465940), foregroundColor: Colors.white),
            child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                : const Text('Publikasikan'),
          )),
        ]),
      ]),
    ),
  );

  @override
  Widget buildFormField({required TextEditingController controller, required String label, required String hint, int maxLines = 1}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 4),
      TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    ],
  );

  @override
  Widget buildTipeDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Tipe Agenda', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedTipe,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'sekolah', child: Text('Sekolah (Umum)')),
              DropdownMenuItem(value: 'perkelas', child: Text('Kelas')),
              DropdownMenuItem(value: 'ekskul', child: Text('Ekstrakurikuler')),
            ],
            onChanged: (String? newValue) {
              setState(() {
                _selectedTipe = newValue!;
                if (_selectedTipe != 'ekskul') _selectedEkstrakulikuler = null;
              });
            },
          ),
        ),
      ),
    ],
  );

  Widget _buildNoKelasWarning() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Informasi Kelas', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(8), color: Colors.orange.withOpacity(0.1)),
        child: Row(children: [
          Icon(Icons.warning, size: 20, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(child: Text('Anda belum memiliki kelas. Hubungi admin untuk ditetapkan sebagai wali kelas.', 
              style: TextStyle(color: Colors.orange.shade800, fontSize: 12))),
        ]),
      ),
    ],
  );

  @override
  Widget buildKelasInfo() {
    if (_kelasGuru == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kelas Tujuan', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFF465940)), borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF465940).withOpacity(0.05)),
          child: Row(children: [
            Icon(Icons.class_, size: 20, color: const Color(0xFF465940)),
            const SizedBox(width: 8),
            Text(_kelasGuru!['nama_kelas'], style: const TextStyle(color: Color(0xFF465940), fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text('(${_kelasGuru!['peran'] ?? 'Guru'})', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 8),
        const Text('Agenda ini hanya untuk kelas Anda', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  @override
  Widget buildEkskulDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Pilih Ekstrakurikuler', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Map<String, dynamic>>(
            value: _selectedEkstrakulikuler,
            isExpanded: true,
            hint: const Text('Pilih ekstrakurikuler...', style: TextStyle(color: Colors.black54)),
            items: _ekskulOptions.map((Map<String, dynamic> ekskul) => 
              DropdownMenuItem<Map<String, dynamic>>(
                value: ekskul,
                child: Text(ekskul['nama'] ?? '', style: const TextStyle(color: Colors.black87)),
              )).toList(),
            onChanged: (Map<String, dynamic>? newValue) => setState(() => _selectedEkstrakulikuler = newValue),
          ),
        ),
      ),
    ],
  );

  @override
  Widget buildDateField() {
    final displayDate = _selectedDate ?? DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tanggal', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(_formatDate(displayDate), style: const TextStyle(color: Colors.black)),
            ]),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildTimeField({required String label, required TimeOfDay? selectedTime, required VoidCallback onTap}) {
    final displayTime = selectedTime != null ? _formatTime(selectedTime) : 'Pilih waktu';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(displayTime, style: TextStyle(color: selectedTime != null ? Colors.black : Colors.black54)),
            ]),
          ),
        ),
      ],
    );
  }
}

class WebAgendaContent extends BaseAgendaContent {
  const WebAgendaContent({super.key});

  @override
  bool get isMobile => false;

  @override
  State<WebAgendaContent> createState() => _WebAgendaContentState();
}

class _WebAgendaContentState extends BaseAgendaContentState<WebAgendaContent> {
  @override
  bool get isMobile => false;

  @override
  Widget buildHeaderWithAddButton() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text('Agenda Sekolah', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F))),
      ElevatedButton.icon(
        onPressed: _toggleForm,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Buat Agenda'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF465940), 
          foregroundColor: Colors.white, 
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
        ),
      ),
    ],
  );

  @override
  Widget buildAgendaList() => _isLoading 
    ? const Center(child: CircularProgressIndicator(color: Color(0xFF465940)))
    : _apiAgendaList.isEmpty 
      ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_note_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('Belum ada agenda', style: TextStyle(fontSize: 18, color: Colors.grey)),
              SizedBox(height: 8),
              Text('Tekan tombol "Buat Agenda" untuk menambahkan', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        )
      : Column(children: _apiAgendaList.map((agenda) => _buildAgendaCard(agenda)).toList());

  Widget _buildAgendaCard(AgendaModel agenda) => Card(
    elevation: 4,
    margin: const EdgeInsets.only(bottom: 20),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(agenda.judul, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F)))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF465940).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(agenda.tipeDisplay, style: TextStyle(color: const Color(0xFF465940), fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 8),
        Text('${_formatDate(agenda.tanggal)} • ${agenda.waktuDisplay}', style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 16),
        Text(agenda.deskripsi, style: const TextStyle(fontSize: 18, color: Colors.black87)),
        const SizedBox(height: 16),
        Text('Tujuan: ${agenda.tujuanDisplay}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF465940))),
        const SizedBox(height: 16),
        Row(children: [
          ElevatedButton(
            onPressed: () => _editAgenda(agenda),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A9B6E), 
              foregroundColor: Colors.white, 
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)
            ),
            child: const Text('Edit'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _deleteAgenda(agenda.agendaId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C), 
              foregroundColor: Colors.white, 
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)
            ),
            child: const Text('Hapus'),
          ),
        ]),
      ]),
    ),
  );

  @override
  Widget buildAgendaForm() => Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_editingAgenda == null ? 'Buat Agenda Baru' : 'Edit Agenda', 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 24),
        buildFormField(controller: _judulController, label: 'Judul Agenda', hint: 'Masukkan judul agenda'),
        const SizedBox(height: 20),
        buildFormField(controller: _deskripsiController, label: 'Deskripsi Agenda', hint: 'Masukkan deskripsi agenda', maxLines: 5),
        const SizedBox(height: 20),
        buildTipeDropdown(),
        const SizedBox(height: 20),
        if (_selectedTipe == "perkelas") buildKelasInfo(),
        if (_selectedTipe == "perkelas" && _kelasGuru == null) _buildNoKelasWarning(),
        if (_selectedTipe == "ekskul") buildEkskulDropdown(),
        const SizedBox(height: 20),
        buildDateField(),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: buildTimeField(label: 'Waktu Mulai', selectedTime: _selectedWaktuMulai, onTap: () => _selectWaktuMulai(context))),
          const SizedBox(width: 16),
          Expanded(child: buildTimeField(label: 'Waktu Selesai', selectedTime: _selectedWaktuSelesai, onTap: () => _selectWaktuSelesai(context))),
        ]),
        const SizedBox(height: 24),
        Row(children: [
          ElevatedButton(
            onPressed: _toggleForm,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            child: const Text('Batal'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _publishAgenda,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF465940), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            child: _isLoading 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
                : const Text('Publikasikan'),
          ),
        ]),
      ]),
    ),
  );

  @override
  Widget buildFormField({required TextEditingController controller, required String label, required String hint, int maxLines = 1}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    ],
  );

  @override
  Widget buildTipeDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Tipe Agenda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedTipe,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'sekolah', child: Text('Sekolah (Umum)', style: TextStyle(fontSize: 16))),
              DropdownMenuItem(value: 'perkelas', child: Text('Kelas', style: TextStyle(fontSize: 16))),
              DropdownMenuItem(value: 'ekskul', child: Text('Ekstrakurikuler', style: TextStyle(fontSize: 16))),
            ],
            onChanged: (String? newValue) {
              setState(() {
                _selectedTipe = newValue!;
                if (_selectedTipe != 'ekskul') _selectedEkstrakulikuler = null;
              });
            },
          ),
        ),
      ),
    ],
  );

  Widget _buildNoKelasWarning() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Informasi Kelas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(8), color: Colors.orange.withOpacity(0.1)),
        child: Row(children: [
          Icon(Icons.warning, size: 24, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(child: Text('Anda belum memiliki kelas. Hubungi admin untuk ditetapkan sebagai wali kelas.', 
              style: TextStyle(color: Colors.orange.shade800, fontSize: 14))),
        ]),
      ),
    ],
  );

  @override
  Widget buildKelasInfo() {
    if (_kelasGuru == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kelas Tujuan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFF465940)), borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF465940).withOpacity(0.05)),
          child: Row(children: [
            Icon(Icons.class_, size: 24, color: const Color(0xFF465940)),
            const SizedBox(width: 12),
            Text(_kelasGuru!['nama_kelas'], style: const TextStyle(fontSize: 18, color: Color(0xFF465940), fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            Text('(${_kelasGuru!['peran'] ?? 'Guru'})', style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ]),
        ),
        const SizedBox(height: 8),
        const Text('Agenda ini hanya untuk kelas Anda', style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  @override
  Widget buildEkskulDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Pilih Ekstrakurikuler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Map<String, dynamic>>(
            value: _selectedEkstrakulikuler,
            isExpanded: true,
            hint: const Text('Pilih ekstrakurikuler...', style: TextStyle(fontSize: 16, color: Colors.black54)),
            items: _ekskulOptions.map((Map<String, dynamic> ekskul) => 
              DropdownMenuItem<Map<String, dynamic>>(
                value: ekskul,
                child: Text(ekskul['nama'] ?? '', style: const TextStyle(fontSize: 16)),
              )).toList(),
            onChanged: (Map<String, dynamic>? newValue) => setState(() => _selectedEkstrakulikuler = newValue),
          ),
        ),
      ),
    ],
  );

  @override
  Widget buildDateField() {
    final displayDate = _selectedDate ?? DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tanggal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(Icons.calendar_today, size: 24, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Text(_formatDate(displayDate), style: const TextStyle(fontSize: 16, color: Colors.black)),
            ]),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildTimeField({required String label, required TimeOfDay? selectedTime, required VoidCallback onTap}) {
    final displayTime = selectedTime != null ? _formatTime(selectedTime) : 'Pilih waktu';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(Icons.access_time, size: 24, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Text(displayTime, style: TextStyle(fontSize: 16, color: selectedTime != null ? Colors.black : Colors.black54)),
            ]),
          ),
        ),
      ],
    );
  }
}