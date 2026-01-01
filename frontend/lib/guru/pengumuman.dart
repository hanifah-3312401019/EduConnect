import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/env/api_base_url.dart';

class PengumumanModel {
  final int pengumumanId;
  final String judul;
  final String isi;
  final String tipe;
  final DateTime tanggal;
  final Map<String, dynamic>? guru;
  final Map<String, dynamic>? kelas;
  final Map<String, dynamic>? siswa;

  PengumumanModel({
    required this.pengumumanId,
    required this.judul,
    required this.isi,
    required this.tipe,
    required this.tanggal,
    this.guru,
    this.kelas,
    this.siswa,
  });

  factory PengumumanModel.fromJson(Map<String, dynamic> json) {
    final tipe = json['Tipe'] ?? json['tipe'] ?? 'Umum';
    final normalizedTipe = tipe.toLowerCase() == 'personal' ? 'Personal' : 
                          tipe.toLowerCase() == 'perkelas' ? 'Perkelas' : 'Umum';
    
    return PengumumanModel(
      pengumumanId: json['Pengumuman_Id'] ?? json['pengumuman_id'] ?? 0,
      judul: json['Judul'] ?? json['judul'] ?? '',
      isi: json['Isi'] ?? json['isi'] ?? '',
      tipe: normalizedTipe,
      tanggal: DateTime.parse(json['Tanggal'] ?? json['tanggal'] ?? DateTime.now().toIso8601String()),
      guru: json['guru'],
      kelas: json['kelas'],
      siswa: json['siswa'],
    );
  }

  String get tujuanDisplay {
    switch (tipe.toLowerCase()) {
      case 'personal':
        return 'Personal - ${siswa?['Nama'] ?? ''}';
      case 'perkelas':
        return 'Kelas - ${kelas?['Nama_Kelas'] ?? ''}';
      default:
        return 'Umum';
    }
  }
}

class PengumumanApiService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api';
  
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

  static Future<List<PengumumanModel>> getPengumumanGuru() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/guru/pengumuman'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((json) => PengumumanModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createPengumuman(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/guru/pengumuman'),
        headers: headers,
        body: json.encode(data),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updatePengumuman(int id, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/guru/pengumuman/$id'),
        headers: headers,
        body: json.encode(data),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deletePengumuman(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/guru/pengumuman/$id'),
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
        Uri.parse('$baseUrl/guru/pengumuman/dropdown-data'),
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

class PengumumanPage extends StatefulWidget {
  const PengumumanPage({Key? key}) : super(key: key);

  @override
  State<PengumumanPage> createState() => _PengumumanPageState();
}

class _PengumumanPageState extends State<PengumumanPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;
        return isMobile ? const MobilePengumumanWithNav() : Scaffold(
          backgroundColor: const Color(0xFFFDFBF0),
          appBar: AppBar(
            title: const Text('Pengumuman', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: const Color(0xFF465940),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer())),
          ),
          drawer: const Sidebar(),
          body: const SafeArea(child: WebPengumumanContent()),
        );
      },
    );
  }
}

class MobilePengumumanWithNav extends StatefulWidget {
  const MobilePengumumanWithNav({super.key});

  @override
  State<MobilePengumumanWithNav> createState() => _MobilePengumumanWithNavState();
}

class _MobilePengumumanWithNavState extends State<MobilePengumumanWithNav> {
  int _currentIndex = 2; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF0),
      appBar: AppBar(
        title: const Text('Pengumuman', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF465940),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer())),
      ),
      drawer: const Sidebar(),
      body: const SafeArea(child: MobilePengumumanContent()),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -2))]),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            switch (index) {
              case 0: Navigator.pushReplacementNamed(context, '/guru/dashboard'); break;
              case 1: Navigator.pushReplacementNamed(context, '/guru/agenda'); break;
              case 2: break; 
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

abstract class BasePengumumanContent extends StatefulWidget {
  const BasePengumumanContent({super.key});
}

abstract class BasePengumumanContentState<T extends BasePengumumanContent> extends State<T> {
  List<PengumumanModel> _apiPengumumanList = [];
  bool _showForm = false;
  PengumumanModel? _editingPengumuman;
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  String _selectedTipe = "Umum";
  Map<String, dynamic>? _selectedKelas;
  Map<String, dynamic>? _selectedSiswa;
  DateTime? _selectedDate;
  final List<String> _tipeOptions = ["Umum", "Perkelas", "Personal"];
  List<Map<String, dynamic>> _kelasOptions = [];
  List<Map<String, dynamic>> _siswaOptions = [];
  bool _isLoading = false;

  bool get isMobile;

  @override
  void initState() {
    super.initState();
    _loadPengumumanFromApi();
    _loadDropdownDataFromApi();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  void _loadPengumumanFromApi() async {
    setState(() => _isLoading = true);
    final pengumuman = await PengumumanApiService.getPengumumanGuru();
    setState(() {
      _apiPengumumanList = pengumuman;
      _isLoading = false;
    });
  }

  void _loadDropdownDataFromApi() async {
  final response = await PengumumanApiService.getDropdownData();
  if (response['success'] == true) {
    setState(() {
      final kelasList = response['data']['kelas'] as List;
      if (kelasList.isNotEmpty) {
        _kelasOptions = kelasList.map((kelas) => {
          'Kelas_Id': kelas['Kelas_Id'],
          'Nama_Kelas': kelas['Nama_Kelas'],
          'peran': kelas['peran'] ?? 'Guru'
        }).toList();
        
        if (_selectedTipe == "Perkelas" && _selectedKelas == null) {
          _selectedKelas = _kelasOptions[0];
        }
      } else {
        _kelasOptions = [];
      }
      
      final siswaList = response['data']['siswa'] as List;
      _siswaOptions = siswaList.map((siswa) => {
        'Siswa_Id': siswa['Siswa_Id'],
        'Nama': siswa['Nama'],
        'Kelas_Nama': siswa['Kelas_Nama'] ?? ''
      }).toList();
    });
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
    _isiController.clear();
    _selectedTipe = "Umum";
    
    if (_selectedTipe != "Perkelas") {
      _selectedKelas = null;
    }
    
    _selectedSiswa = null;
    _selectedDate = DateTime.now();
    _editingPengumuman = null;
  }

  void _editPengumuman(PengumumanModel pengumuman) {
    setState(() {
      _editingPengumuman = pengumuman;
      _judulController.text = pengumuman.judul;
      _isiController.text = pengumuman.isi;
      _selectedDate = pengumuman.tanggal;
      _showForm = true;

      final tipeFromDb = pengumuman.tipe;
      if (tipeFromDb.toLowerCase() == 'personal') {
        _selectedTipe = "Personal";
      } else if (tipeFromDb.toLowerCase() == 'perkelas') {
        _selectedTipe = "Perkelas"; 
      } else {
        _selectedTipe = "Umum";
      }
      
      _selectedKelas = null;
      _selectedSiswa = null;
      
      if (_selectedTipe == "Personal" && pengumuman.siswa != null) {
        try {
          _selectedSiswa = _siswaOptions.firstWhere(
            (siswa) => siswa['Siswa_Id'] == pengumuman.siswa!['Siswa_Id']
          );
        } catch (e) {
          _selectedSiswa = null;
        }
      } 
      
      if (_selectedTipe == "Perkelas") {
        if (_kelasOptions.isNotEmpty) {
          _selectedKelas = _kelasOptions[0];
        }
      }
    });
  }

  void _deletePengumuman(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengumuman'),
        content: const Text('Apakah Anda yakin ingin menghapus pengumuman ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Batal')
          ),
          TextButton(
            onPressed: () {
              _deletePengumumanFromApi(id);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deletePengumumanFromApi(int id) async {
    final response = await PengumumanApiService.deletePengumuman(id);
    if (response['success'] == true) {
      _loadPengumumanFromApi();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Pengumuman berhasil dihapus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${response['message']}')),
      );
    }
  }

  void _publishPengumuman() {
    if (_selectedDate == null) {
      _selectedDate = DateTime.now();
    }
    
    if (_judulController.text.isEmpty || _isiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Judul dan isi harus diisi'))
      );
      return;
    }
    
    if (_selectedTipe == "Personal" && _selectedSiswa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pilih siswa untuk pengumuman personal'))
      );
      return;
    }
    
    if (_selectedTipe == "Perkelas") {
      if (_kelasOptions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Guru belum memiliki kelas untuk membuat pengumuman perkelas'))
        );
        return;
      }
      if (_selectedKelas == null) {
        _selectedKelas = _kelasOptions[0];
      }
    }
    
    final tipeForApi = _selectedTipe.toLowerCase();

    final Map<String, dynamic> pengumumanData = {
      'Judul': _judulController.text,
      'Isi': _isiController.text,
      'Tipe': tipeForApi, 
      'Tanggal': _selectedDate!.toIso8601String().split('.').first,
    };

    if (_selectedTipe == 'Perkelas' && _selectedKelas != null) {
      pengumumanData['Kelas_Id'] = _selectedKelas!['Kelas_Id'];
    }

    if (_selectedTipe == 'Personal' && _selectedSiswa != null) {
      pengumumanData['Siswa_Id'] = _selectedSiswa!['Siswa_Id'];
    }

    _publishPengumumanToApi(pengumumanData);
  }

  void _publishPengumumanToApi(Map<String, dynamic> data) async {
    setState(() => _isLoading = true);
    
    try {
      final response = _editingPengumuman != null 
          ? await PengumumanApiService.updatePengumuman(_editingPengumuman!.pengumumanId, data)
          : await PengumumanApiService.createPengumuman(data);

      setState(() => _isLoading = false);

      if (response['success'] == true) {
        _loadPengumumanFromApi();
        setState(() {
          _showForm = false;
          _resetForm();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Pengumuman berhasil dipublikasikan')),
        );
      } else {
        final errorMessage = response['message'] ?? 'Terjadi kesalahan';
        final errors = response['errors'] ?? {};
        
        String detailedError = errorMessage;
        if (errors.isNotEmpty) {
          detailedError += '\nDetail: $errors';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $detailedError'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
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

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';

  String _getMonthName(int month) => ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][month];

  Widget buildHeaderWithAddButton();
  Widget buildPengumumanList();
  Widget buildPengumumanForm();
  Widget buildFormField({required TextEditingController controller, required String label, required String hint, int maxLines = 1});
  Widget buildTipeDropdown();
  Widget buildKelasInfo();
  Widget buildSiswaDropdown();
  Widget buildDateField();

  @override
  Widget build(BuildContext context) {
    if (!_tipeOptions.contains(_selectedTipe)) {
      final matchedTipe = _tipeOptions.firstWhere(
        (option) => option.toLowerCase() == _selectedTipe.toLowerCase(),
        orElse: () => _tipeOptions.first
      );
      _selectedTipe = matchedTipe;
    }
    
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: isMobile ? const EdgeInsets.all(16) : const EdgeInsets.all(32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (!_showForm) buildHeaderWithAddButton(),
            if (!_showForm) buildPengumumanList() else buildPengumumanForm(),
            SizedBox(height: isMobile ? 20 : 40),
          ]),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Color(0xFF465940)),
            ),
          ),
      ],
    );
  }
}

class MobilePengumumanContent extends BasePengumumanContent {
  const MobilePengumumanContent({super.key});

  @override
  bool get isMobile => true;

  @override
  State<MobilePengumumanContent> createState() => _MobilePengumumanContentState();
}

class _MobilePengumumanContentState extends BasePengumumanContentState<MobilePengumumanContent> {
  @override
  bool get isMobile => true;

  @override
  Widget buildHeaderWithAddButton() => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Pengumuman Sekolah', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 12),
      Align(alignment: Alignment.centerRight, child: ElevatedButton.icon(
        onPressed: _toggleForm,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Buat Pengumuman'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF465940), 
          foregroundColor: Colors.white, 
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
        ),
      )),
    ]),
  );

  @override
  Widget buildPengumumanList() => _isLoading 
    ? const Center(child: CircularProgressIndicator(color: Color(0xFF465940)))
    : _apiPengumumanList.isEmpty 
      ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.announcement_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Belum ada pengumuman', style: TextStyle(fontSize: 16, color: Colors.grey)),
              SizedBox(height: 8),
              Text('Tekan tombol "Buat Pengumuman" untuk menambahkan', 
                   style: TextStyle(fontSize: 14, color: Colors.grey),
                   textAlign: TextAlign.center),
            ],
          ),
        )
      : Column(children: _apiPengumumanList.map((pengumuman) => _buildPengumumanCard(pengumuman)).toList());

  Widget _buildPengumumanCard(PengumumanModel pengumuman) => Card(
    elevation: 2,
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(pengumuman.judul, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F)))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF465940).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              pengumuman.tipe,
              style: TextStyle(
                color: const Color(0xFF465940),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Text(_formatDate(pengumuman.tanggal), style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 12),
        Text(pengumuman.isi, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 12),
        Text(
          'Tujuan: ${pengumuman.tujuanDisplay}', 
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF465940))
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: ElevatedButton(
            onPressed: () => _editPengumuman(pengumuman),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A9B6E), 
              foregroundColor: Colors.white
            ),
            child: const Text('Edit'),
          )),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(
            onPressed: () => _deletePengumuman(pengumuman.pengumumanId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C), 
              foregroundColor: Colors.white
            ),
            child: const Text('Hapus'),
          )),
        ]),
      ]),
    ),
  );

  @override
  Widget buildPengumumanForm() => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_editingPengumuman == null ? 'Buat Pengumuman Baru' : 'Edit Pengumuman', 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 20),
        buildFormField(controller: _judulController, label: 'Judul Pengumuman', hint: 'Masukkan judul pengumuman'),
        const SizedBox(height: 16),
        buildFormField(controller: _isiController, label: 'Isi Pengumuman', hint: 'Masukkan isi pengumuman', maxLines: 4),
        const SizedBox(height: 16),
        buildTipeDropdown(),
        if (_selectedTipe == "Perkelas") ...[
          const SizedBox(height: 16),
          buildKelasInfo(),
        ],
        if (_selectedTipe == "Personal") ...[
          const SizedBox(height: 16),
          buildSiswaDropdown(),
        ],
        const SizedBox(height: 16),
        buildDateField(),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: ElevatedButton(
            onPressed: _toggleForm,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
            child: const Text('Batal'),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: _isLoading ? null : _publishPengumuman,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF465940), 
              foregroundColor: Colors.white
            ),
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
  Widget buildTipeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipe Pengumuman', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400), 
            borderRadius: BorderRadius.circular(8)
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTipe,
              isExpanded: true,
              items: _tipeOptions.map((String value) => 
                DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(color: Colors.black87)),
                )).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTipe = newValue!;
                  
                  if (_selectedTipe != "Personal") {
                    _selectedSiswa = null;
                  }
                  
                  if (_selectedTipe == "Perkelas") {
                    if (_kelasOptions.isNotEmpty) {
                      _selectedKelas = _kelasOptions[0];
                    } else {
                      _selectedKelas = null;
                    }
                  } else if (_selectedTipe != "Perkelas") {
                    _selectedKelas = null;
                  }
                  
                  if (_selectedTipe == "Umum") {
                    _selectedKelas = null;
                    _selectedSiswa = null;
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildKelasInfo() {
    if (_kelasOptions.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kelas', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400), 
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: const Text(
              'Guru belum memiliki kelas yang ditugaskan',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kelas Tujuan', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF465940)), 
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF465940).withOpacity(0.05),
          ),
          child: Row(
            children: [
              Icon(Icons.class_, size: 20, color: const Color(0xFF465940)),
              const SizedBox(width: 8),
              Text(
                _kelasOptions[0]['Nama_Kelas'],
                style: const TextStyle(
                  color: Color(0xFF465940),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '(Kelas Anda)',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pengumuman akan dikirim ke seluruh siswa di kelas ini',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget buildSiswaDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Pilih Siswa', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400), 
          borderRadius: BorderRadius.circular(8)
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Map<String, dynamic>>(
            value: _selectedSiswa,
            isExpanded: true,
            hint: const Text('Pilih siswa...', style: TextStyle(color: Colors.black54)),
            items: _siswaOptions.map((Map<String, dynamic> siswa) => 
              DropdownMenuItem<Map<String, dynamic>>(
                value: siswa,
                child: Text(siswa['Nama'], style: const TextStyle(color: Colors.black87)),
              )).toList(),
            onChanged: (Map<String, dynamic>? newValue) => setState(() => _selectedSiswa = newValue),
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
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400), 
              borderRadius: BorderRadius.circular(8)
            ),
            child: Row(children: [
              Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                _formatDate(displayDate),
                style: const TextStyle(color: Colors.black)
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class WebPengumumanContent extends BasePengumumanContent {
  const WebPengumumanContent({super.key});

  @override
  bool get isMobile => false;

  @override
  State<WebPengumumanContent> createState() => _WebPengumumanContentState();
}

class _WebPengumumanContentState extends BasePengumumanContentState<WebPengumumanContent> {
  @override
  bool get isMobile => false;

  @override
  Widget buildHeaderWithAddButton() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text('Pengumuman Sekolah', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F))),
      ElevatedButton.icon(
        onPressed: _toggleForm,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Buat Pengumuman'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF465940), 
          foregroundColor: Colors.white, 
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
        ),
      ),
    ],
  );

  @override
  Widget buildPengumumanList() => _isLoading 
    ? const Center(child: CircularProgressIndicator(color: Color(0xFF465940)))
    : _apiPengumumanList.isEmpty 
      ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.announcement_outlined, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('Belum ada pengumuman', style: TextStyle(fontSize: 18, color: Colors.grey)),
              SizedBox(height: 8),
              Text('Tekan tombol "Buat Pengumuman" untuk menambahkan', 
                   style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        )
      : Column(children: _apiPengumumanList.map((pengumuman) => _buildPengumumanCard(pengumuman)).toList());

  Widget _buildPengumumanCard(PengumumanModel pengumuman) => Card(
    elevation: 4,
    margin: const EdgeInsets.only(bottom: 20),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(pengumuman.judul, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F)))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF465940).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              pengumuman.tipe,
              style: TextStyle(
                color: const Color(0xFF465940),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Text(_formatDate(pengumuman.tanggal), style: const TextStyle(color: Colors.grey, fontSize: 16)),
        const SizedBox(height: 16),
        Text(pengumuman.isi, style: const TextStyle(fontSize: 18, color: Colors.black87)),
        const SizedBox(height: 16),
        Text(
          'Tujuan: ${pengumuman.tujuanDisplay}', 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF465940))
        ),
        const SizedBox(height: 16),
        Row(children: [
          ElevatedButton(
            onPressed: () => _editPengumuman(pengumuman),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8A9B6E), 
              foregroundColor: Colors.white, 
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)
            ),
            child: const Text('Edit'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _deletePengumuman(pengumuman.pengumumanId),
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
  Widget buildPengumumanForm() => Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_editingPengumuman == null ? 'Buat Pengumuman Baru' : 'Edit Pengumuman', 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 24),
        buildFormField(controller: _judulController, label: 'Judul Pengumuman', hint: 'Masukkan judul pengumuman'),
        const SizedBox(height: 20),
        buildFormField(controller: _isiController, label: 'Isi Pengumuman', hint: 'Masukkan isi pengumuman', maxLines: 5),
        const SizedBox(height: 20),
        buildTipeDropdown(),
        if (_selectedTipe == "Perkelas") ...[
          const SizedBox(height: 20),
          buildKelasInfo(),
        ],
        if (_selectedTipe == "Personal") ...[
          const SizedBox(height: 20),
          buildSiswaDropdown(),
        ],
        const SizedBox(height: 20),
        buildDateField(),
        const SizedBox(height: 24),
        Row(children: [
          ElevatedButton(
            onPressed: _toggleForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey, 
              foregroundColor: Colors.white, 
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
            ),
            child: const Text('Batal'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _publishPengumuman,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF465940), 
              foregroundColor: Colors.white, 
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)
            ),
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
  Widget buildTipeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipe Pengumuman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400), 
            borderRadius: BorderRadius.circular(8)
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTipe,
              isExpanded: true,
              items: _tipeOptions.map((String value) => 
                DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                )).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTipe = newValue!;
                  
                  if (_selectedTipe != "Personal") {
                    _selectedSiswa = null;
                  }
                  
                  if (_selectedTipe == "Perkelas") {
                    if (_kelasOptions.isNotEmpty) {
                      _selectedKelas = _kelasOptions[0];
                    } else {
                      _selectedKelas = null;
                    }
                  } else if (_selectedTipe != "Perkelas") {
                    _selectedKelas = null;
                  }
                  
                  if (_selectedTipe == "Umum") {
                    _selectedKelas = null;
                    _selectedSiswa = null;
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget buildKelasInfo() {
    if (_kelasOptions.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Kelas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400), 
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: const Text(
              'Guru belum memiliki kelas yang ditugaskan',
              style: TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kelas Tujuan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF465940)), 
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF465940).withOpacity(0.05),
          ),
          child: Row(
            children: [
              Icon(Icons.class_, size: 24, color: const Color(0xFF465940)),
              const SizedBox(width: 12),
              Text(
                _kelasOptions[0]['Nama_Kelas'],
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF465940),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '(Kelas Anda)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pengumuman akan dikirim ke seluruh siswa di kelas ini',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget buildSiswaDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Pilih Siswa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400), 
          borderRadius: BorderRadius.circular(8)
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Map<String, dynamic>>(
            value: _selectedSiswa,
            isExpanded: true,
            hint: const Text('Pilih siswa...', style: TextStyle(fontSize: 16, color: Colors.black54)),
            items: _siswaOptions.map((Map<String, dynamic> siswa) => 
              DropdownMenuItem<Map<String, dynamic>>(
                value: siswa,
                child: Text(siswa['Nama'], style: const TextStyle(fontSize: 16, color: Colors.black87)),
              )).toList(),
            onChanged: (Map<String, dynamic>? newValue) => setState(() => _selectedSiswa = newValue),
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
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400), 
              borderRadius: BorderRadius.circular(8)
            ),
            child: Row(children: [
              Icon(Icons.calendar_today, size: 24, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              Text(
                _formatDate(displayDate),
                style: const TextStyle(color: Colors.black)
              ),
            ]),
          ),
        ),
      ],
    );
  }
}