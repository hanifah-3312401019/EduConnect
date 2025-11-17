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
    AgendaItem(
      id: 1,
      deskripsi: "Rapat Wali Murid",
      tujuan: "Personal",
      tanggal: DateTime(2025, 11, 10),
      waktuMulai: TimeOfDay(hour: 8, minute: 0),
      waktuSelesai: TimeOfDay(hour: 10, minute: 0),
    ),
    AgendaItem(
      id: 2,
      deskripsi: "Acara Memperingati Hari Pancasila",
      tujuan: "Umum",
      tanggal: DateTime(2025, 3, 20),
      waktuMulai: TimeOfDay(hour: 8, minute: 0),
      waktuSelesai: TimeOfDay(hour: 10, minute: 0),
    ),
    AgendaItem(
      id: 3,
      deskripsi: "Latihan Nari Kelas 3A",
      tujuan: "Perkelas",
      tanggal: DateTime(2025, 11, 17),
      waktuMulai: TimeOfDay(hour: 7, minute: 0),
      waktuSelesai: TimeOfDay(hour: 8, minute: 0),
    ),
  ];

  bool _showForm = false;
  AgendaItem? _editingAgenda;

  final _deskripsiController = TextEditingController();
  String _selectedTujuan = "Umum";
  DateTime? _selectedDate;
  TimeOfDay? _selectedWaktuMulai;
  TimeOfDay? _selectedWaktuSelesai;

  final List<String> _tujuanOptions = ["Umum", "Perkelas", "Personal"];

  @override
  void dispose() {
    _deskripsiController.dispose();
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
    _deskripsiController.clear();
    _selectedTujuan = "Umum";
    _selectedDate = null;
    _selectedWaktuMulai = null;
    _selectedWaktuSelesai = null;
    _editingAgenda = null;
  }

  void _editAgenda(AgendaItem agenda) {
    setState(() {
      _editingAgenda = agenda;
      _deskripsiController.text = agenda.deskripsi;
      _selectedTujuan = agenda.tujuan;
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _agendaList.removeWhere((p) => p.id == id);
              });
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _publishAgenda() {
    if (_deskripsiController.text.isEmpty ||
        _selectedDate == null ||
        _selectedWaktuMulai == null ||
        _selectedWaktuSelesai == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field harus diisi')));
      return;
    }

    setState(() {
      if (_editingAgenda != null) {
        final index = _agendaList.indexWhere((p) => p.id == _editingAgenda!.id);
        if (index != -1) {
          _agendaList[index] = AgendaItem(
            id: _editingAgenda!.id,
            deskripsi: _deskripsiController.text,
            tujuan: _selectedTujuan,
            tanggal: _selectedDate!,
            waktuMulai: _selectedWaktuMulai!,
            waktuSelesai: _selectedWaktuSelesai!,
          );
        }
      } else {
        final newId = _agendaList.isEmpty
            ? 1
            : _agendaList.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;

        _agendaList.add(
          AgendaItem(
            id: newId,
            deskripsi: _deskripsiController.text,
            tujuan: _selectedTujuan,
            tanggal: _selectedDate!,
            waktuMulai: _selectedWaktuMulai!,
            waktuSelesai: _selectedWaktuSelesai!,
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

  Future<void> _selectWaktuMulai(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedWaktuMulai ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedWaktuMulai = picked;
      });
    }
  }

  Future<void> _selectWaktuSelesai(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedWaktuSelesai ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedWaktuSelesai = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'Mei';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Agu';
      case 9:
        return 'Sep';
      case 10:
        return 'Okt';
      case 11:
        return 'Nov';
      case 12:
        return 'Des';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF0),
      appBar: AppBar(title: const Text('Agenda Sekolah')),
      drawer: const Sidebar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (!_showForm) ...[
                    _buildAgendaList(),
                    const SizedBox(height: 20),
                    _buildAddButton(),
                  ] else
                    _buildAgendaForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaList() {
    if (_agendaList.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada agenda',
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      );
    }

    return Column(
      children: _agendaList.map((agenda) => _buildAgendaCard(agenda)).toList(),
    );
  }

  Widget _buildAgendaCard(AgendaItem agenda) {
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
                    agenda.deskripsi,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F3B1F),
                    ),
                  ),
                ),
                Text(
                  _formatDate(agenda.tanggal),
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatTime(agenda.waktuMulai)} - ${_formatTime(agenda.waktuSelesai)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2F3B1F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tujuan: ${agenda.tujuan}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _editAgenda(agenda),
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
                    onPressed: () => _deleteAgenda(agenda.id),
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
            Text('Tambahkan Data'),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingAgenda == null ? 'Tambah Agenda Baru' : 'Edit Agenda',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2F3B1F),
              ),
            ),
            const SizedBox(height: 20),

            // DESKRIPSI → sekarang jadi field utama
            _buildFormField(
              controller: _deskripsiController,
              label: 'Deskripsi Agenda',
              hint: 'Masukkan deskripsi agenda',
              maxLines: 3,
            ),

            const SizedBox(height: 16),
            _buildTujuanDropdown(),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildWaktuMulaiField()),
                const SizedBox(width: 12),
                Expanded(child: _buildWaktuSelesaiField()),
              ],
            ),

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
                    onPressed: _publishAgenda,
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
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F3B1F),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black54),
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

  Widget _buildTujuanDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tujuan Agenda',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F3B1F),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedTujuan,
              isExpanded: true,
              items: _tujuanOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.black87),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedTujuan = newValue!;
                });
              },
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
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F3B1F),
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
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaktuMulaiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Waktu Mulai',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F3B1F),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _selectWaktuMulai(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  _selectedWaktuMulai != null
                      ? _formatTime(_selectedWaktuMulai!)
                      : 'Pilih waktu',
                  style: TextStyle(
                    color: _selectedWaktuMulai != null
                        ? Colors.black
                        : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaktuSelesaiField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Waktu Selesai',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2F3B1F),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _selectWaktuSelesai(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  _selectedWaktuSelesai != null
                      ? _formatTime(_selectedWaktuSelesai!)
                      : 'Pilih waktu',
                  style: TextStyle(
                    color: _selectedWaktuSelesai != null
                        ? Colors.black
                        : Colors.black54,
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

// MODEL BARU TANPA JUDUL
class AgendaItem {
  final int id;
  final String deskripsi;
  final String tujuan;
  final DateTime tanggal;
  final TimeOfDay waktuMulai;
  final TimeOfDay waktuSelesai;

  AgendaItem({
    required this.id,
    required this.deskripsi,
    required this.tujuan,
    required this.tanggal,
    required this.waktuMulai,
    required this.waktuSelesai,
  });
}
