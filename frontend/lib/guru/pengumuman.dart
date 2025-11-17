import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'package:intl/intl.dart';

class Pengumuman extends StatefulWidget {
  const Pengumuman({Key? key}) : super(key: key);

  @override
  State<Pengumuman> createState() => _PengumumanState();
}

class _PengumumanState extends State<Pengumuman> {
  final List<PengumumanItem> _pengumumanList = [
    PengumumanItem(
      id: 1,
      judul: "Libur Lebaran",
      isi:
          "Libur Lebaran akan dilaksanakan mulai tanggal 10-04-2024 sampai tanggal 20-04-2025",
      tujuan: "Semua Siswa dan Guru",
      tanggal: DateTime(2024, 4, 10),
    ),
    PengumumanItem(
      id: 2,
      judul: "Pengambilan Rapot",
      isi:
          "Pengambilan rapot semester genap akan dilaksanakan pada tanggal 15-05-2025",
      tujuan: "Semua Siswa dan Orang Tua",
      tanggal: DateTime(2025, 5, 15),
    ),
  ];

  bool _showForm = false;
  PengumumanItem? _editingPengumuman;

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

  void _toggleForm() {
    setState(() {
      _showForm = !_showForm;
      if (!_showForm) {
        _resetForm();
      }
    });
  }

  void _resetForm() {
    _judulController.clear();
    _isiController.clear();
    _tujuanController.clear();
    _selectedDate = null;
    _editingPengumuman = null;
  }

  void _editPengumuman(PengumumanItem pengumuman) {
    setState(() {
      _editingPengumuman = pengumuman;
      _judulController.text = pengumuman.judul;
      _isiController.text = pengumuman.isi;
      _tujuanController.text = pengumuman.tujuan;
      _selectedDate = pengumuman.tanggal;
      _showForm = true;
    });
  }

  void _deletePengumuman(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengumuman'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pengumuman ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _pengumumanList.removeWhere((p) => p.id == id);
              });
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _publishPengumuman() {
    if (_judulController.text.isEmpty ||
        _isiController.text.isEmpty ||
        _tujuanController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    setState(() {
      if (_editingPengumuman != null) {
        // Edit existing
        final index = _pengumumanList.indexWhere(
          (p) => p.id == _editingPengumuman!.id,
        );
        if (index != -1) {
          _pengumumanList[index] = PengumumanItem(
            id: _editingPengumuman!.id,
            judul: _judulController.text,
            isi: _isiController.text,
            tujuan: _tujuanController.text,
            tanggal: _selectedDate!,
          );
        }
      } else {
        // Add new
        final newId = _pengumumanList.isEmpty
            ? 1
            : _pengumumanList.map((p) => p.id).reduce((a, b) => a > b ? a : b) +
                  1;
        _pengumumanList.add(
          PengumumanItem(
            id: newId,
            judul: _judulController.text,
            isi: _isiController.text,
            tujuan: _tujuanController.text,
            tanggal: _selectedDate!,
          ),
        );
      }
      _showForm = false;
      _resetForm();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF0),
      appBar: AppBar(title: const Text('Pengumuman')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (!_showForm) ...[
                    _buildAnnouncementList(),
                    const SizedBox(height: 20),
                    _buildAddButton(),
                  ] else
                    _buildAnnouncementForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementList() {
    if (_pengumumanList.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada pengumuman',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return Column(
      children: _pengumumanList
          .map((pengumuman) => _buildAnnouncementCard(pengumuman))
          .toList(),
    );
  }

  Widget _buildAnnouncementCard(PengumumanItem pengumuman) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pengumuman.judul,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                Text(
                  _formatDate(pengumuman.tanggal),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(pengumuman.isi, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(
              'Tujuan: ${pengumuman.tujuan}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
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

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _toggleForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF465940),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 20),
            SizedBox(width: 8),
            Text('Tambah Pengumuman'),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingPengumuman == null
                  ? 'Tambah Pengumuman Baru'
                  : 'Edit Pengumuman',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 20),
            _buildFormField(
              controller: _judulController,
              label: 'Judul Pengumuman',
              hint: 'Masukkan judul pengumuman',
            ),
            const SizedBox(height: 16),
            _buildFormField(
              controller: _isiController,
              label: 'Isi Pengumuman',
              hint: 'Masukkan isi pengumuman',
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            _buildFormField(
              controller: _tujuanController,
              label: 'Tujuan Pengumuman',
              hint: 'Masukkan tujuan pengumuman',
            ),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _toggleForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _publishPengumuman,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF465940),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Publikasikan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
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
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
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
        const SizedBox(height: 4),
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
                  _selectedDate != null
                      ? _formatDate(_selectedDate!)
                      : 'Pilih tanggal',
                  style: TextStyle(
                    color: _selectedDate != null
                        ? Colors.black
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
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
