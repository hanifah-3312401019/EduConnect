import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/sidebar.dart';

class Agenda extends StatefulWidget {
  const Agenda({Key? key}) : super(key: key);

  @override
  State<Agenda> createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  final List<AgendaItem> _agendaList = [
    AgendaItem(1, "Rapat Wali Murid", "Pertemuan rutin wali murid kelas 1A", "Kelas", DateTime(2025, 11, 10), TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 10, minute: 0), "1A"),
    AgendaItem(2, "Acara Memperingati Hari Pancasila", "Upacara dan lomba untuk memperingati Hari Pancasila", "Sekolah", DateTime(2025, 3, 20), TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 10, minute: 0), ""),
    AgendaItem(3, "Latihan Nari Kelas 3A", "Latihan tari tradisional untuk persiapan pentas seni", "Ekstrakurikuler", DateTime(2025, 11, 17), TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 8, minute: 0), ""),
  ];

  bool _showForm = false;
  AgendaItem? _editingAgenda;
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String _selectedTujuan = "Sekolah";
  String _selectedKelas = "";
  DateTime? _selectedDate;
  TimeOfDay? _selectedWaktuMulai;
  TimeOfDay? _selectedWaktuSelesai;
  final List<String> _tujuanOptions = ["Sekolah", "Kelas", "Ekstrakurikuler"];
  final List<String> _kelasOptions = ["1A", "1B", "2A", "2B", "3A", "3B", "4A", "4B", "5A", "5B", "6A", "6B"];

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
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
    _selectedTujuan = "Sekolah";
    _selectedKelas = "";
    _selectedDate = null;
    _selectedWaktuMulai = null;
    _selectedWaktuSelesai = null;
    _editingAgenda = null;
  }

  void _editAgenda(AgendaItem agenda) {
    setState(() {
      _editingAgenda = agenda;
      _judulController.text = agenda.judul;
      _deskripsiController.text = agenda.deskripsi;
      _selectedTujuan = agenda.tujuan;
      _selectedKelas = agenda.kelas;
      _selectedDate = agenda.tanggal;
      _selectedWaktuMulai = agenda.waktuMulai;
      _selectedWaktuSelesai = agenda.waktuSelesai;
      _showForm = true;
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
            onPressed: () {
              setState(() => _agendaList.removeWhere((p) => p.id == id));
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _publishAgenda() {
    if (_judulController.text.isEmpty || _deskripsiController.text.isEmpty || _selectedDate == null || _selectedWaktuMulai == null || _selectedWaktuSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    if (_selectedTujuan == "Kelas" && _selectedKelas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kelas untuk tujuan Kelas')));
      return;
    }

    setState(() {
      if (_editingAgenda != null) {
        final index = _agendaList.indexWhere((p) => p.id == _editingAgenda!.id);
        if (index != -1) {
          _agendaList[index] = AgendaItem(_editingAgenda!.id, _judulController.text, _deskripsiController.text, _selectedTujuan, _selectedDate!, _selectedWaktuMulai!, _selectedWaktuSelesai!, _selectedKelas);
        }
      } else {
        final newId = _agendaList.isEmpty ? 1 : _agendaList.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
        _agendaList.add(AgendaItem(newId, _judulController.text, _deskripsiController.text, _selectedTujuan, _selectedDate!, _selectedWaktuMulai!, _selectedWaktuSelesai!, _selectedKelas));
      }
      _showForm = false;
      _resetForm();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

  Future<void> _selectWaktuMulai(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedWaktuMulai ?? TimeOfDay.now());
    if (picked != null) setState(() => _selectedWaktuMulai = picked);
  }

  Future<void> _selectWaktuSelesai(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedWaktuSelesai ?? TimeOfDay.now());
    if (picked != null) setState(() => _selectedWaktuSelesai = picked);
  }

  String _formatTime(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';

  String _getMonthName(int month) => ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][month];

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
            leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer())),
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
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF0),
      appBar: AppBar(
        title: const Text('Agenda', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF465940),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer())),
      ),
      drawer: const Sidebar(),
      body: const SafeArea(child: MobileAgendaContent()),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -2))]),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            switch (index) {
              case 0: Navigator.pushReplacementNamed(context, '/guru/dashboard'); break;
              case 1: Navigator.pushReplacementNamed(context, '/guru/absensi'); break;
              case 2: break;
              case 3: Navigator.pushReplacementNamed(context, '/guru/pengumuman'); break;
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
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Absensi'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Agenda'),
            BottomNavigationBarItem(icon: Icon(Icons.announcement), label: 'Pengumuman'),
          ],
        ),
      ),
    );
  }
}

class MobileAgendaContent extends StatefulWidget {
  const MobileAgendaContent({super.key});

  @override
  State<MobileAgendaContent> createState() => _MobileAgendaContentState();
}

class _MobileAgendaContentState extends State<MobileAgendaContent> {
  final List<AgendaItem> _agendaList = [
    AgendaItem(1, "Rapat Wali Murid", "Pertemuan rutin wali murid kelas 1A", "Kelas", DateTime(2025, 11, 10), TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 10, minute: 0), "1A"),
    AgendaItem(2, "Acara Memperingati Hari Pancasila", "Upacara dan lomba untuk memperingati Hari Pancasila", "Sekolah", DateTime(2025, 3, 20), TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 10, minute: 0), ""),
    AgendaItem(3, "Latihan Nari Kelas 3A", "Latihan tari tradisional untuk persiapan pentas seni", "Ekstrakurikuler", DateTime(2025, 11, 17), TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 8, minute: 0), ""),
    AgendaItem(4, "Ujian Semester Genap", "Ujian akhir semester untuk semua kelas", "Sekolah", DateTime(2025, 6, 15), TimeOfDay(hour: 7, minute: 30), TimeOfDay(hour: 12, minute: 0), ""),
    AgendaItem(5, "Pembagian Raport", "Pembagian raport semester genap", "Sekolah", DateTime(2025, 6, 28), TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 11, minute: 0), ""),
  ];

  bool _showForm = false;
  AgendaItem? _editingAgenda;
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String _selectedTujuan = "Sekolah";
  String _selectedKelas = "";
  DateTime? _selectedDate;
  TimeOfDay? _selectedWaktuMulai;
  TimeOfDay? _selectedWaktuSelesai;
  final List<String> _tujuanOptions = ["Sekolah", "Kelas", "Ekstrakurikuler"];
  final List<String> _kelasOptions = ["1A", "1B", "2A", "2B", "3A", "3B", "4A", "4B", "5A", "5B", "6A", "6B"];

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
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
    _selectedTujuan = "Sekolah";
    _selectedKelas = "";
    _selectedDate = null;
    _selectedWaktuMulai = null;
    _selectedWaktuSelesai = null;
    _editingAgenda = null;
  }

  void _editAgenda(AgendaItem agenda) {
    setState(() {
      _editingAgenda = agenda;
      _judulController.text = agenda.judul;
      _deskripsiController.text = agenda.deskripsi;
      _selectedTujuan = agenda.tujuan;
      _selectedKelas = agenda.kelas;
      _selectedDate = agenda.tanggal;
      _selectedWaktuMulai = agenda.waktuMulai;
      _selectedWaktuSelesai = agenda.waktuSelesai;
      _showForm = true;
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
            onPressed: () {
              setState(() => _agendaList.removeWhere((p) => p.id == id));
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _publishAgenda() {
    if (_judulController.text.isEmpty || _deskripsiController.text.isEmpty || _selectedDate == null || _selectedWaktuMulai == null || _selectedWaktuSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    if (_selectedTujuan == "Kelas" && _selectedKelas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kelas untuk tujuan Kelas')));
      return;
    }

    setState(() {
      if (_editingAgenda != null) {
        final index = _agendaList.indexWhere((p) => p.id == _editingAgenda!.id);
        if (index != -1) {
          _agendaList[index] = AgendaItem(_editingAgenda!.id, _judulController.text, _deskripsiController.text, _selectedTujuan, _selectedDate!, _selectedWaktuMulai!, _selectedWaktuSelesai!, _selectedKelas);
        }
      } else {
        final newId = _agendaList.isEmpty ? 1 : _agendaList.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
        _agendaList.add(AgendaItem(newId, _judulController.text, _deskripsiController.text, _selectedTujuan, _selectedDate!, _selectedWaktuMulai!, _selectedWaktuSelesai!, _selectedKelas));
      }
      _showForm = false;
      _resetForm();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

  Future<void> _selectWaktuMulai(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedWaktuMulai ?? TimeOfDay.now());
    if (picked != null) setState(() => _selectedWaktuMulai = picked);
  }

  Future<void> _selectWaktuSelesai(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedWaktuSelesai ?? TimeOfDay.now());
    if (picked != null) setState(() => _selectedWaktuSelesai = picked);
  }

  String _formatTime(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';

  String _getMonthName(int month) => ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][month];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        if (!_showForm) _buildHeaderWithAddButton(),
        if (!_showForm) _buildAgendaList() else _buildAgendaForm(),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildHeaderWithAddButton() => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Agenda Sekolah', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 12),
      Align(alignment: Alignment.centerRight, child: ElevatedButton.icon(
        onPressed: _toggleForm,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Tambahkan Data'),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF465940), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
      )),
    ]),
  );

  Widget _buildAgendaList() => _agendaList.isEmpty 
    ? const Center(child: Text('Belum ada agenda', style: TextStyle(fontSize: 16, color: Colors.black87)))
    : Column(children: _agendaList.map((agenda) => _buildAgendaCard(agenda)).toList());

  Widget _buildAgendaCard(AgendaItem agenda) => Card(
    elevation: 2,
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(agenda.judul, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F)))),
          Text(_formatDate(agenda.tanggal), style: const TextStyle(color: Colors.black87, fontSize: 14)),
        ]),
        const SizedBox(height: 8),
        Text(agenda.deskripsi, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 8),
        Text('${_formatTime(agenda.waktuMulai)} - ${_formatTime(agenda.waktuSelesai)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 8),
        Text('Tujuan: ${agenda.tujuan}${agenda.kelas.isNotEmpty ? ' - ${agenda.kelas}' : ''}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: ElevatedButton(
            onPressed: () => _editAgenda(agenda),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A9B6E), foregroundColor: Colors.white),
            child: const Text('Edit'),
          )),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(
            onPressed: () => _deleteAgenda(agenda.id),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE74C3C), foregroundColor: Colors.white),
            child: const Text('Hapus'),
          )),
        ]),
      ]),
    ),
  );

  Widget _buildAgendaForm() => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_editingAgenda == null ? 'Tambah Agenda Baru' : 'Edit Agenda', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 20),
        _buildFormField(controller: _judulController, label: 'Judul Agenda', hint: 'Masukkan judul agenda', maxLines: 1),
        const SizedBox(height: 16),
        _buildFormField(controller: _deskripsiController, label: 'Deskripsi Agenda', hint: 'Masukkan deskripsi agenda', maxLines: 3),
        const SizedBox(height: 16),
        _buildTujuanDropdown(),
        if (_selectedTujuan == "Kelas") ...[
          const SizedBox(height: 16),
          _buildKelasDropdown(),
        ],
        const SizedBox(height: 16),
        _buildDateField(),
        const SizedBox(height: 16),
        Row(children: [Expanded(child: _buildWaktuMulaiField()), const SizedBox(width: 12), Expanded(child: _buildWaktuSelesaiField())]),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: ElevatedButton(
            onPressed: _toggleForm,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
            child: const Text('Batal'),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: _publishAgenda,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF465940), foregroundColor: Colors.white),
            child: const Text('Publikasikan'),
          )),
        ]),
      ]),
    ),
  );

  Widget _buildFormField({required TextEditingController controller, required String label, required String hint, int maxLines = 1}) => Column(
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

  Widget _buildTujuanDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Tujuan Agenda', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedTujuan,
            isExpanded: true,
            items: _tujuanOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(color: Colors.black87)))).toList(),
            onChanged: (String? newValue) => setState(() {
              _selectedTujuan = newValue!;
              if (_selectedTujuan != "Kelas") {
                _selectedKelas = "";
              }
            }),
          ),
        ),
      ),
    ],
  );

  Widget _buildKelasDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Pilih Kelas', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedKelas.isEmpty ? null : _selectedKelas,
            isExpanded: true,
            hint: const Text('Pilih Kelas', style: TextStyle(color: Colors.black54)),
            items: _kelasOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(color: Colors.black87)))).toList(),
            onChanged: (String? newValue) => setState(() => _selectedKelas = newValue!),
          ),
        ),
      ),
    ],
  );

  Widget _buildDateField() => Column(
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
            Text(_selectedDate != null ? _formatDate(_selectedDate!) : 'Pilih tanggal', style: TextStyle(color: _selectedDate != null ? Colors.black : Colors.black54)),
          ]),
        ),
      ),
    ],
  );

  Widget _buildWaktuMulaiField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Waktu Mulai', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 4),
      InkWell(
        onTap: () => _selectWaktuMulai(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(_selectedWaktuMulai != null ? _formatTime(_selectedWaktuMulai!) : 'Pilih waktu', style: TextStyle(color: _selectedWaktuMulai != null ? Colors.black : Colors.black54)),
          ]),
        ),
      ),
    ],
  );

  Widget _buildWaktuSelesaiField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Waktu Selesai', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 4),
      InkWell(
        onTap: () => _selectWaktuSelesai(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(_selectedWaktuSelesai != null ? _formatTime(_selectedWaktuSelesai!) : 'Pilih waktu', style: TextStyle(color: _selectedWaktuSelesai != null ? Colors.black : Colors.black54)),
          ]),
        ),
      ),
    ],
  );
}

class WebAgendaContent extends StatefulWidget {
  const WebAgendaContent({super.key});

  @override
  State<WebAgendaContent> createState() => _WebAgendaContentState();
}

class _WebAgendaContentState extends State<WebAgendaContent> {
  final List<AgendaItem> _agendaList = [
    AgendaItem(1, "Rapat Wali Murid", "Pertemuan rutin wali murid kelas 1A", "Kelas", DateTime(2025, 11, 10), TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 10, minute: 0), "1A"),
    AgendaItem(2, "Acara Memperingati Hari Pancasila", "Upacara dan lomba untuk memperingati Hari Pancasila", "Sekolah", DateTime(2025, 3, 20), TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 10, minute: 0), ""),
    AgendaItem(3, "Latihan Nari Kelas 3A", "Latihan tari tradisional untuk persiapan pentas seni", "Ekstrakurikuler", DateTime(2025, 11, 17), TimeOfDay(hour: 7, minute: 0), TimeOfDay(hour: 8, minute: 0), ""),
    AgendaItem(4, "Ujian Semester Genap", "Ujian akhir semester untuk semua kelas", "Sekolah", DateTime(2025, 6, 15), TimeOfDay(hour: 7, minute: 30), TimeOfDay(hour: 12, minute: 0), ""),
    AgendaItem(5, "Pembagian Raport", "Pembagian raport semester genap", "Sekolah", DateTime(2025, 6, 28), TimeOfDay(hour: 8, minute: 0), TimeOfDay(hour: 11, minute: 0), ""),
    AgendaItem(6, "Workshop Guru", "Pelatihan metode pembelajaran terbaru untuk guru", "Kelas", DateTime(2025, 7, 5), TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 15, minute: 0), "3B"),
  ];

  bool _showForm = false;
  AgendaItem? _editingAgenda;
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String _selectedTujuan = "Sekolah";
  String _selectedKelas = "";
  DateTime? _selectedDate;
  TimeOfDay? _selectedWaktuMulai;
  TimeOfDay? _selectedWaktuSelesai;
  final List<String> _tujuanOptions = ["Sekolah", "Kelas", "Ekstrakurikuler"];
  final List<String> _kelasOptions = ["1A", "1B", "2A", "2B", "3A", "3B", "4A", "4B", "5A", "5B", "6A", "6B"];

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
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
    _selectedTujuan = "Sekolah";
    _selectedKelas = "";
    _selectedDate = null;
    _selectedWaktuMulai = null;
    _selectedWaktuSelesai = null;
    _editingAgenda = null;
  }

  void _editAgenda(AgendaItem agenda) {
    setState(() {
      _editingAgenda = agenda;
      _judulController.text = agenda.judul;
      _deskripsiController.text = agenda.deskripsi;
      _selectedTujuan = agenda.tujuan;
      _selectedKelas = agenda.kelas;
      _selectedDate = agenda.tanggal;
      _selectedWaktuMulai = agenda.waktuMulai;
      _selectedWaktuSelesai = agenda.waktuSelesai;
      _showForm = true;
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
            onPressed: () {
              setState(() => _agendaList.removeWhere((p) => p.id == id));
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _publishAgenda() {
    if (_judulController.text.isEmpty || _deskripsiController.text.isEmpty || _selectedDate == null || _selectedWaktuMulai == null || _selectedWaktuSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    if (_selectedTujuan == "Kelas" && _selectedKelas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kelas untuk tujuan Kelas')));
      return;
    }

    setState(() {
      if (_editingAgenda != null) {
        final index = _agendaList.indexWhere((p) => p.id == _editingAgenda!.id);
        if (index != -1) {
          _agendaList[index] = AgendaItem(_editingAgenda!.id, _judulController.text, _deskripsiController.text, _selectedTujuan, _selectedDate!, _selectedWaktuMulai!, _selectedWaktuSelesai!, _selectedKelas);
        }
      } else {
        final newId = _agendaList.isEmpty ? 1 : _agendaList.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
        _agendaList.add(AgendaItem(newId, _judulController.text, _deskripsiController.text, _selectedTujuan, _selectedDate!, _selectedWaktuMulai!, _selectedWaktuSelesai!, _selectedKelas));
      }
      _showForm = false;
      _resetForm();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

  Future<void> _selectWaktuMulai(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedWaktuMulai ?? TimeOfDay.now());
    if (picked != null) setState(() => _selectedWaktuMulai = picked);
  }

  Future<void> _selectWaktuSelesai(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedWaktuSelesai ?? TimeOfDay.now());
    if (picked != null) setState(() => _selectedWaktuSelesai = picked);
  }

  String _formatTime(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';

  String _getMonthName(int month) => ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][month];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildHeaderWithAddButton(),
        const SizedBox(height: 24),
        if (!_showForm) _buildAgendaList() else _buildAgendaForm(),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _buildHeaderWithAddButton() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text('Agenda Sekolah', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F))),
      ElevatedButton.icon(
        onPressed: _toggleForm,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Tambahkan Data'),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF465940), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
      ),
    ],
  );

  Widget _buildAgendaList() => _agendaList.isEmpty 
    ? const Center(child: Text('Belum ada agenda', style: TextStyle(fontSize: 18, color: Colors.black87)))
    : Column(children: _agendaList.map((agenda) => _buildAgendaCard(agenda)).toList());

  Widget _buildAgendaCard(AgendaItem agenda) => Card(
    elevation: 4,
    margin: const EdgeInsets.only(bottom: 20),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(agenda.judul, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F)))),
          Text(_formatDate(agenda.tanggal), style: const TextStyle(color: Colors.black87, fontSize: 16)),
        ]),
        const SizedBox(height: 12),
        Text(agenda.deskripsi, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 12),
        Text('${_formatTime(agenda.waktuMulai)} - ${_formatTime(agenda.waktuSelesai)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 8),
        Text('Tujuan: ${agenda.tujuan}${agenda.kelas.isNotEmpty ? ' - ${agenda.kelas}' : ''}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 16),
        Row(children: [
          ElevatedButton(
            onPressed: () => _editAgenda(agenda),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A9B6E), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            child: const Text('Edit'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _deleteAgenda(agenda.id),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE74C3C), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            child: const Text('Hapus'),
          ),
        ]),
      ]),
    ),
  );

  Widget _buildAgendaForm() => Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_editingAgenda == null ? 'Tambah Agenda Baru' : 'Edit Agenda', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 24),
        _buildFormField(controller: _judulController, label: 'Judul Agenda', hint: 'Masukkan judul agenda', maxLines: 1),
        const SizedBox(height: 20),
        _buildFormField(controller: _deskripsiController, label: 'Deskripsi Agenda', hint: 'Masukkan deskripsi agenda', maxLines: 3),
        const SizedBox(height: 20),
        _buildTujuanDropdown(),
        if (_selectedTujuan == "Kelas") ...[
          const SizedBox(height: 20),
          _buildKelasDropdown(),
        ],
        const SizedBox(height: 20),
        _buildDateField(),
        const SizedBox(height: 20),
        Row(children: [Expanded(child: _buildWaktuMulaiField()), const SizedBox(width: 16), Expanded(child: _buildWaktuSelesaiField())]),
        const SizedBox(height: 24),
        Row(children: [
          ElevatedButton(
            onPressed: _toggleForm,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            child: const Text('Batal'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _publishAgenda,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF465940), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            child: const Text('Publikasikan'),
          ),
        ]),
      ]),
    ),
  );

  Widget _buildFormField({required TextEditingController controller, required String label, required String hint, int maxLines = 1}) => Column(
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

  Widget _buildTujuanDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Tujuan Agenda', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedTujuan,
            isExpanded: true,
            items: _tujuanOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)))).toList(),
            onChanged: (String? newValue) => setState(() {
              _selectedTujuan = newValue!;
              if (_selectedTujuan != "Kelas") {
                _selectedKelas = "";
              }
            }),
          ),
        ),
      ),
    ],
  );

  Widget _buildKelasDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Pilih Kelas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedKelas.isEmpty ? null : _selectedKelas,
            isExpanded: true,
            hint: const Text('Pilih Kelas', style: TextStyle(fontSize: 16, color: Colors.black54)),
            items: _kelasOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)))).toList(),
            onChanged: (String? newValue) => setState(() => _selectedKelas = newValue!),
          ),
        ),
      ),
    ],
  );

  Widget _buildDateField() => Column(
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
            Text(_selectedDate != null ? _formatDate(_selectedDate!) : 'Pilih tanggal', style: TextStyle(fontSize: 16, color: _selectedDate != null ? Colors.black : Colors.black54)),
          ]),
        ),
      ),
    ],
  );

  Widget _buildWaktuMulaiField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Waktu Mulai', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 8),
      InkWell(
        onTap: () => _selectWaktuMulai(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Icon(Icons.access_time, size: 24, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(_selectedWaktuMulai != null ? _formatTime(_selectedWaktuMulai!) : 'Pilih waktu', style: TextStyle(fontSize: 16, color: _selectedWaktuMulai != null ? Colors.black : Colors.black54)),
          ]),
        ),
      ),
    ],
  );

  Widget _buildWaktuSelesaiField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Waktu Selesai', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 8),
      InkWell(
        onTap: () => _selectWaktuSelesai(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            Icon(Icons.access_time, size: 24, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(_selectedWaktuSelesai != null ? _formatTime(_selectedWaktuSelesai!) : 'Pilih waktu', style: TextStyle(fontSize: 16, color: _selectedWaktuSelesai != null ? Colors.black : Colors.black54)),
          ]),
        ),
      ),
    ],
  );
}

class AgendaItem {
  final int id;
  final String judul;
  final String deskripsi;
  final String tujuan;
  final DateTime tanggal;
  final TimeOfDay waktuMulai;
  final TimeOfDay waktuSelesai;
  final String kelas;

  AgendaItem(this.id, this.judul, this.deskripsi, this.tujuan, this.tanggal, this.waktuMulai, this.waktuSelesai, this.kelas);
}