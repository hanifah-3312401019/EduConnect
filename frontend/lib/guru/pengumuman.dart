import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';

class Pengumuman extends StatefulWidget {
  const Pengumuman({Key? key}) : super(key: key);

  @override
  State<Pengumuman> createState() => _PengumumanState();
}

class _PengumumanState extends State<Pengumuman> {
  final List<PengumumanItem> _pengumumanList = [
    PengumumanItem(1, "Libur Lebaran", "Libur Lebaran akan dilaksanakan mulai tanggal 10-04-2024 sampai tanggal 20-04-2025", "Umum", DateTime(2024, 4, 10)),
    PengumumanItem(2, "Pengambilan Rapot", "Pengambilan rapot semester genap akan dilaksanakan pada tanggal 15-05-2025", "Umum", DateTime(2025, 5, 15)),
    PengumumanItem(3, "Ujian Semester Genap", "Ujian semester genap akan dilaksanakan mulai tanggal 1-06-2025. Seluruh siswa diharapkan mempersiapkan diri dengan baik.", "Perkelas", DateTime(2025, 6, 1)),
    PengumumanItem(4, "Pembagian Buku LKS", "Pembagian buku LKS semester depan akan dilaksanakan pada tanggal 25-05-2025. Harap mengambil di perpustakaan.", "Perkelas", DateTime(2025, 5, 25)),
  ];

  bool _showForm = false;
  PengumumanItem? _editingPengumuman;
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  String _selectedTujuan = "Umum";
  String? _selectedSiswa;
  DateTime? _selectedDate;
  final List<String> _tujuanOptions = ["Umum", "Perkelas", "Personal"];
  final List<String> _siswaOptions = [
    "Siti Nurhalis", "Farhan Abas", "Rafi Ahmad", "Anmay Musa", 
    "Rasya Likhan", "Yogi Yaya", "Yupis Yupi", "Rasya Zeyfarsyah", "Raffa Zeyfarsyah"
  ];

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
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
    _isiController.clear();
    _selectedTujuan = "Umum";
    _selectedSiswa = null;
    _selectedDate = null;
    _editingPengumuman = null;
  }

  void _editPengumuman(PengumumanItem pengumuman) {
    setState(() {
      _editingPengumuman = pengumuman;
      _judulController.text = pengumuman.judul;
      _isiController.text = pengumuman.isi;
      _selectedDate = pengumuman.tanggal;
      _showForm = true;

      // Handle tujuan untuk pengumuman yang sudah ada
      if (pengumuman.tujuan.startsWith("Personal - ")) {
        _selectedTujuan = "Personal";
        _selectedSiswa = pengumuman.tujuan.replaceAll("Personal - ", "");
      } else {
        _selectedTujuan = pengumuman.tujuan;
        _selectedSiswa = null;
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              setState(() => _pengumumanList.removeWhere((p) => p.id == id));
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _publishPengumuman() {
    if (_judulController.text.isEmpty || _isiController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    if (_selectedTujuan == "Personal" && _selectedSiswa == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih siswa untuk tujuan Personal')));
      return;
    }

    setState(() {
      if (_editingPengumuman != null) {
        final index = _pengumumanList.indexWhere((p) => p.id == _editingPengumuman!.id);
        if (index != -1) {
          final tujuanDisplay = _selectedTujuan == "Personal" ? "Personal - $_selectedSiswa" : _selectedTujuan;
          _pengumumanList[index] = PengumumanItem(_editingPengumuman!.id, _judulController.text, _isiController.text, tujuanDisplay, _selectedDate!);
        }
      } else {
        final newId = _pengumumanList.isEmpty ? 1 : _pengumumanList.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
        final tujuanDisplay = _selectedTujuan == "Personal" ? "Personal - $_selectedSiswa" : _selectedTujuan;
        _pengumumanList.add(PengumumanItem(newId, _judulController.text, _isiController.text, tujuanDisplay, _selectedDate!));
      }
      _showForm = false;
      _resetForm();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';

  String _getMonthName(int month) => ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][month];

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
  int _currentIndex = 3;

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
              case 1: Navigator.pushReplacementNamed(context, '/guru/absensi'); break;
              case 2: Navigator.pushReplacementNamed(context, '/guru/agenda'); break;
              case 3: break;
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

class MobilePengumumanContent extends StatefulWidget {
  const MobilePengumumanContent({super.key});

  @override
  State<MobilePengumumanContent> createState() => _MobilePengumumanContentState();
}

class _MobilePengumumanContentState extends State<MobilePengumumanContent> {
  final List<PengumumanItem> _pengumumanList = [
    PengumumanItem(1, "Libur Lebaran", "Libur Lebaran akan dilaksanakan mulai tanggal 10-04-2024 sampai tanggal 20-04-2025", "Umum", DateTime(2024, 4, 10)),
    PengumumanItem(2, "Pengambilan Rapot", "Pengambilan rapot semester genap akan dilaksanakan pada tanggal 15-05-2025", "Umum", DateTime(2025, 5, 15)),
    PengumumanItem(3, "Ujian Semester Genap", "Ujian semester genap akan dilaksanakan mulai tanggal 1-06-2025. Seluruh siswa diharapkan mempersiapkan diri dengan baik.", "Perkelas", DateTime(2025, 6, 1)),
    PengumumanItem(4, "Pembagian Buku LKS", "Pembagian buku LKS semester depan akan dilaksanakan pada tanggal 25-05-2025. Harap mengambil di perpustakaan.", "Perkelas", DateTime(2025, 5, 25)),
  ];

  bool _showForm = false;
  PengumumanItem? _editingPengumuman;
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  String _selectedTujuan = "Umum";
  String? _selectedSiswa;
  DateTime? _selectedDate;
  final List<String> _tujuanOptions = ["Umum", "Perkelas", "Personal"];
  final List<String> _siswaOptions = [
    "Siti Nurhalis", "Farhan Abas", "Rafi Ahmad", "Anmay Musa", 
    "Rasya Likhan", "Yogi Yaya", "Yupis Yupi", "Rasya Zeyfarsyah", "Raffa Zeyfarsyah"
  ];

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
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
    _isiController.clear();
    _selectedTujuan = "Umum";
    _selectedSiswa = null;
    _selectedDate = null;
    _editingPengumuman = null;
  }

  void _editPengumuman(PengumumanItem pengumuman) {
    setState(() {
      _editingPengumuman = pengumuman;
      _judulController.text = pengumuman.judul;
      _isiController.text = pengumuman.isi;
      _selectedDate = pengumuman.tanggal;
      _showForm = true;

      // Handle tujuan untuk pengumuman yang sudah ada
      if (pengumuman.tujuan.startsWith("Personal - ")) {
        _selectedTujuan = "Personal";
        _selectedSiswa = pengumuman.tujuan.replaceAll("Personal - ", "");
      } else {
        _selectedTujuan = pengumuman.tujuan;
        _selectedSiswa = null;
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              setState(() => _pengumumanList.removeWhere((p) => p.id == id));
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _publishPengumuman() {
    if (_judulController.text.isEmpty || _isiController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    if (_selectedTujuan == "Personal" && _selectedSiswa == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih siswa untuk tujuan Personal')));
      return;
    }

    setState(() {
      if (_editingPengumuman != null) {
        final index = _pengumumanList.indexWhere((p) => p.id == _editingPengumuman!.id);
        if (index != -1) {
          final tujuanDisplay = _selectedTujuan == "Personal" ? "Personal - $_selectedSiswa" : _selectedTujuan;
          _pengumumanList[index] = PengumumanItem(_editingPengumuman!.id, _judulController.text, _isiController.text, tujuanDisplay, _selectedDate!);
        }
      } else {
        final newId = _pengumumanList.isEmpty ? 1 : _pengumumanList.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
        final tujuanDisplay = _selectedTujuan == "Personal" ? "Personal - $_selectedSiswa" : _selectedTujuan;
        _pengumumanList.add(PengumumanItem(newId, _judulController.text, _isiController.text, tujuanDisplay, _selectedDate!));
      }
      _showForm = false;
      _resetForm();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';

  String _getMonthName(int month) => ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][month];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        if (!_showForm) _buildHeaderWithAddButton(),
        if (!_showForm) _buildPengumumanList() else _buildPengumumanForm(),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _buildHeaderWithAddButton() => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Pengumuman Sekolah', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 12),
      Align(alignment: Alignment.centerRight, child: ElevatedButton.icon(
        onPressed: _toggleForm,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Tambahkan Data'),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF465940), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
      )),
    ]),
  );

  Widget _buildPengumumanList() => _pengumumanList.isEmpty 
    ? const Center(child: Text('Belum ada pengumuman', style: TextStyle(fontSize: 16, color: Colors.black87)))
    : Column(children: _pengumumanList.map((pengumuman) => _buildPengumumanCard(pengumuman)).toList());

  Widget _buildPengumumanCard(PengumumanItem pengumuman) => Card(
    elevation: 2,
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(pengumuman.judul, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F)))),
          Text(_formatDate(pengumuman.tanggal), style: const TextStyle(color: Colors.black87, fontSize: 14)),
        ]),
        const SizedBox(height: 8),
        Text(pengumuman.isi, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 8),
        Text(
          'Tujuan: ${pengumuman.tujuan}', 
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: ElevatedButton(
            onPressed: () => _editPengumuman(pengumuman),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A9B6E), foregroundColor: Colors.white),
            child: const Text('Edit'),
          )),
          const SizedBox(width: 8),
          Expanded(child: ElevatedButton(
            onPressed: () => _deletePengumuman(pengumuman.id),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE74C3C), foregroundColor: Colors.white),
            child: const Text('Hapus'),
          )),
        ]),
      ]),
    ),
  );

  Widget _buildPengumumanForm() => Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_editingPengumuman == null ? 'Tambah Pengumuman Baru' : 'Edit Pengumuman', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 20),
        _buildFormField(controller: _judulController, label: 'Judul Pengumuman', hint: 'Masukkan judul pengumuman'),
        const SizedBox(height: 16),
        _buildFormField(controller: _isiController, label: 'Isi Pengumuman', hint: 'Masukkan isi pengumuman', maxLines: 4),
        const SizedBox(height: 16),
        _buildTujuanDropdown(),
        if (_selectedTujuan == "Personal") ...[
          const SizedBox(height: 16),
          _buildSiswaDropdown(),
        ],
        const SizedBox(height: 16),
        _buildDateField(),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: ElevatedButton(
            onPressed: _toggleForm,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white),
            child: const Text('Batal'),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: _publishPengumuman,
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
      const Text('Tujuan Pengumuman', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
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
            onChanged: (String? newValue) {
              setState(() {
                _selectedTujuan = newValue!;
                if (_selectedTujuan != "Personal") {
                  _selectedSiswa = null;
                }
              });
            },
          ),
        ),
      ),
    ],
  );

  Widget _buildSiswaDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Pilih Siswa', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedSiswa,
            isExpanded: true,
            hint: const Text('Pilih siswa...', style: TextStyle(color: Colors.black54)),
            items: _siswaOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(color: Colors.black87)))).toList(),
            onChanged: (String? newValue) => setState(() => _selectedSiswa = newValue),
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
}

class WebPengumumanContent extends StatefulWidget {
  const WebPengumumanContent({super.key});

  @override
  State<WebPengumumanContent> createState() => _WebPengumumanContentState();
}

class _WebPengumumanContentState extends State<WebPengumumanContent> {
  final List<PengumumanItem> _pengumumanList = [
    PengumumanItem(1, "Libur Lebaran", "Libur Lebaran akan dilaksanakan mulai tanggal 10-04-2024 sampai tanggal 20-04-2025", "Umum", DateTime(2024, 4, 10)),
    PengumumanItem(2, "Pengambilan Rapot", "Pengambilan rapot semester genap akan dilaksanakan pada tanggal 15-05-2025", "Umum", DateTime(2025, 5, 15)),
    PengumumanItem(3, "Ujian Semester Genap", "Ujian semester genap akan dilaksanakan mulai tanggal 1-06-2025. Seluruh siswa diharapkan mempersiapkan diri dengan baik.", "Perkelas", DateTime(2025, 6, 1)),
    PengumumanItem(4, "Pembagian Buku LKS", "Pembagian buku LKS semester depan akan dilaksanakan pada tanggal 25-05-2025. Harap mengambil di perpustakaan.", "Perkelas", DateTime(2025, 5, 25)),
    PengumumanItem(5, "Workshop Pendidikan Karakter", "Workshop pendidikan karakter untuk guru akan dilaksanakan pada tanggal 30-05-2025. Diwajibkan untuk semua guru.", "Personal - Siti Nurhalis", DateTime(2025, 5, 30)),
    PengumumanItem(6, "Perpisahan Kelas 6", "Acara perpisahan untuk siswa kelas 6 akan dilaksanakan pada tanggal 20-06-2025. Mari kita siapkan acara yang berkesan.", "Umum", DateTime(2025, 6, 20)),
  ];

  bool _showForm = false;
  PengumumanItem? _editingPengumuman;
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  String _selectedTujuan = "Umum";
  String? _selectedSiswa;
  DateTime? _selectedDate;
  final List<String> _tujuanOptions = ["Umum", "Perkelas", "Personal"];
  final List<String> _siswaOptions = [
    "Siti Nurhalis", "Farhan Abas", "Rafi Ahmad", "Anmay Musa", 
    "Rasya Likhan", "Yogi Yaya", "Yupis Yupi", "Rasya Zeyfarsyah", "Raffa Zeyfarsyah"
  ];

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
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
    _isiController.clear();
    _selectedTujuan = "Umum";
    _selectedSiswa = null;
    _selectedDate = null;
    _editingPengumuman = null;
  }

  void _editPengumuman(PengumumanItem pengumuman) {
    setState(() {
      _editingPengumuman = pengumuman;
      _judulController.text = pengumuman.judul;
      _isiController.text = pengumuman.isi;
      _selectedDate = pengumuman.tanggal;
      _showForm = true;

      // Handle tujuan untuk pengumuman yang sudah ada
      if (pengumuman.tujuan.startsWith("Personal - ")) {
        _selectedTujuan = "Personal";
        _selectedSiswa = pengumuman.tujuan.replaceAll("Personal - ", "");
      } else {
        _selectedTujuan = pengumuman.tujuan;
        _selectedSiswa = null;
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              setState(() => _pengumumanList.removeWhere((p) => p.id == id));
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _publishPengumuman() {
    if (_judulController.text.isEmpty || _isiController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    if (_selectedTujuan == "Personal" && _selectedSiswa == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih siswa untuk tujuan Personal')));
      return;
    }

    setState(() {
      if (_editingPengumuman != null) {
        final index = _pengumumanList.indexWhere((p) => p.id == _editingPengumuman!.id);
        if (index != -1) {
          final tujuanDisplay = _selectedTujuan == "Personal" ? "Personal - $_selectedSiswa" : _selectedTujuan;
          _pengumumanList[index] = PengumumanItem(_editingPengumuman!.id, _judulController.text, _isiController.text, tujuanDisplay, _selectedDate!);
        }
      } else {
        final newId = _pengumumanList.isEmpty ? 1 : _pengumumanList.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
        final tujuanDisplay = _selectedTujuan == "Personal" ? "Personal - $_selectedSiswa" : _selectedTujuan;
        _pengumumanList.add(PengumumanItem(newId, _judulController.text, _isiController.text, tujuanDisplay, _selectedDate!));
      }
      _showForm = false;
      _resetForm();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

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
        if (!_showForm) _buildPengumumanList() else _buildPengumumanForm(),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _buildHeaderWithAddButton() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text('Pengumuman Sekolah', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F))),
      ElevatedButton.icon(
        onPressed: _toggleForm,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Tambahkan Data'),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF465940), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
      ),
    ],
  );

  Widget _buildPengumumanList() => _pengumumanList.isEmpty 
    ? const Center(child: Text('Belum ada pengumuman', style: TextStyle(fontSize: 18, color: Colors.black87)))
    : Column(children: _pengumumanList.map((pengumuman) => _buildPengumumanCard(pengumuman)).toList());

  Widget _buildPengumumanCard(PengumumanItem pengumuman) => Card(
    elevation: 4,
    margin: const EdgeInsets.only(bottom: 20),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(pengumuman.judul, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F)))),
          Text(_formatDate(pengumuman.tanggal), style: const TextStyle(color: Colors.black87, fontSize: 16)),
        ]),
        const SizedBox(height: 12),
        Text(pengumuman.isi, style: const TextStyle(fontSize: 18, color: Colors.black87)),
        const SizedBox(height: 12),
        Text(
          'Tujuan: ${pengumuman.tujuan}', 
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)
        ),
        const SizedBox(height: 16),
        Row(children: [
          ElevatedButton(
            onPressed: () => _editPengumuman(pengumuman),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8A9B6E), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            child: const Text('Edit'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _deletePengumuman(pengumuman.id),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE74C3C), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
            child: const Text('Hapus'),
          ),
        ]),
      ]),
    ),
  );

  Widget _buildPengumumanForm() => Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_editingPengumuman == null ? 'Tambah Pengumuman Baru' : 'Edit Pengumuman', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2F3B1F))),
        const SizedBox(height: 24),
        _buildFormField(controller: _judulController, label: 'Judul Pengumuman', hint: 'Masukkan judul pengumuman'),
        const SizedBox(height: 20),
        _buildFormField(controller: _isiController, label: 'Isi Pengumuman', hint: 'Masukkan isi pengumuman', maxLines: 5),
        const SizedBox(height: 20),
        _buildTujuanDropdown(),
        if (_selectedTujuan == "Personal") ...[
          const SizedBox(height: 20),
          _buildSiswaDropdown(),
        ],
        const SizedBox(height: 20),
        _buildDateField(),
        const SizedBox(height: 24),
        Row(children: [
          ElevatedButton(
            onPressed: _toggleForm,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            child: const Text('Batal'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _publishPengumuman,
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
      const Text('Tujuan Pengumuman', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
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
            onChanged: (String? newValue) {
              setState(() {
                _selectedTujuan = newValue!;
                if (_selectedTujuan != "Personal") {
                  _selectedSiswa = null;
                }
              });
            },
          ),
        ),
      ),
    ],
  );

  Widget _buildSiswaDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Pilih Siswa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2F3B1F))),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedSiswa,
            isExpanded: true,
            hint: const Text('Pilih siswa...', style: TextStyle(fontSize: 16, color: Colors.black54)),
            items: _siswaOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)))).toList(),
            onChanged: (String? newValue) => setState(() => _selectedSiswa = newValue),
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
}

class PengumumanItem {
  final int id;
  final String judul;
  final String isi;
  final String tujuan;
  final DateTime tanggal;

  PengumumanItem(this.id, this.judul, this.isi, this.tujuan, this.tanggal);
}