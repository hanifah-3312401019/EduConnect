import 'package:flutter/material.dart';

class WebPengumuman extends StatefulWidget {
  const WebPengumuman({Key? key}) : super(key: key);

  @override
  State<WebPengumuman> createState() => _WebPengumumanState();
}

class _WebPengumumanState extends State<WebPengumuman> {
  final List<PengumumanItem> _pengumumanList = [
    PengumumanItem(
      id: 1,
      judul: "Libur Lebaran",
      isi: "Libur Lebaran akan dilaksanakan mulai tanggal 10-04-2024 sampai tanggal 20-04-2025",
      tujuan: "Semua Siswa dan Guru",
      tanggal: DateTime(2024, 4, 10),
    ),
    PengumumanItem(
      id: 2,
      judul: "Pengambilan Rapot",
      isi: "Pengambilan rapot semester genap akan dilaksanakan pada tanggal 15-05-2025",
      tujuan: "Semua Siswa dan Orang Tua",
      tanggal: DateTime(2025, 5, 15),
    ),
  ];

  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  final _tujuanController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    _tujuanController.dispose();
    super.dispose();
  }

  void _publishPengumuman() {
    if (_judulController.text.isEmpty ||
        _isiController.text.isEmpty ||
        _tujuanController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    setState(() {
      final newId = _pengumumanList.isEmpty
          ? 1
          : _pengumumanList.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
      _pengumumanList.add(
        PengumumanItem(
          id: newId,
          judul: _judulController.text,
          isi: _isiController.text,
          tujuan: _tujuanController.text,
          tanggal: _selectedDate!,
        ),
      );

      // Reset form
      _judulController.clear();
      _isiController.clear();
      _tujuanController.clear();
      _selectedDate = null;
    });
  }

  void _editPengumuman(PengumumanItem pengumuman) {
    // Implementation for edit
  }

  void _deletePengumuman(int id) {
    setState(() {
      _pengumumanList.removeWhere((p) => p.id == id);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Ganti semua DateFormat dengan fungsi _formatDate
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF0),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sidebar
            _buildSidebar(),
            const SizedBox(width: 24),
            // Main Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 32),
                  // Content
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Announcement List
                        Expanded(
                          flex: 2,
                          child: _buildAnnouncementList(),
                        ),
                        const SizedBox(width: 24),
                        // Form Section
                        Expanded(
                          flex: 1,
                          child: _buildFormSection(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSidebarItem(Icons.home, 'Beranda', true),
          _buildSidebarItem(Icons.person, 'Guru', false),
          _buildSidebarItem(Icons.school, 'Siswa', false),
          _buildSidebarItem(Icons.announcement, 'Pengumuman', false),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String text, bool isActive) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF465940).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFF465940) : Colors.grey,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: isActive ? const Color(0xFF465940) : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Pengumuman',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF465940),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF465940),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.person, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Admin Guru',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementList() {
    return Column(
      children: [
        // Announcement Cards
        Expanded(
          child: ListView(
            children: _pengumumanList.map((pengumuman) => _buildAnnouncementCard(pengumuman)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(PengumumanItem pengumuman) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pengumuman.judul,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF465940),
                    ),
                  ),
                ),
                Text(
                  // Di _buildAnnouncementCard, ganti:
                  // DateFormat('dd-MM-yyyy').format(pengumuman.tanggal)
                  // menjadi:
                  _formatDate(pengumuman.tanggal),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(pengumuman.isi),
            const SizedBox(height: 8),
            Text(
              'Tujuan: ${pengumuman.tujuan}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _editPengumuman(pengumuman),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A9B6E),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _deletePengumuman(pengumuman.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengumuman Baru',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF465940),
              ),
            ),
            const SizedBox(height: 20),
            _buildWebFormField(_judulController, 'Judul Pengumuman'),
            const SizedBox(height: 16),
            _buildWebFormField(_isiController, 'Isi Pengumuman', maxLines: 4),
            const SizedBox(height: 16),
            _buildWebFormField(_tujuanController, 'Tujuan Pengumuman'),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _publishPengumuman,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF465940),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Publikasikan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebFormField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF465940),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12),
              border: InputBorder.none,
              hintText: 'Masukkan $label',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF465940),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  // Di _buildDateField, ganti:
                  // DateFormat('dd-MM-yyyy').format(_selectedDate!)
                  // menjadi:
                  _selectedDate != null
                      ? _formatDate(_selectedDate!)
                      : 'Pilih tanggal',
                  style: TextStyle(
                    color: _selectedDate != null ? Colors.black : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PengumumanItem {
  final int id;
  final String judul;
  final String isi;
  final String tujuan;
  final DateTime tanggal;

  PengumumanItem({
    required this.id,
    required this.judul,
    required this.isi,
    required this.tujuan,
    required this.tanggal,
  });
}