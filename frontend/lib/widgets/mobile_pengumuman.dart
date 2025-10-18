import 'package:flutter/material.dart';

class MobilePengumuman extends StatefulWidget {
  const MobilePengumuman({Key? key}) : super(key: key);

  @override
  State<MobilePengumuman> createState() => _MobilePengumumanState();
}

class _MobilePengumumanState extends State<MobilePengumuman> {
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

  int _currentIndex = 3;

  void _editPengumuman(PengumumanItem pengumuman) {
    _showAnnouncementDialog(context, true, pengumuman: pengumuman);
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
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _pengumumanList.removeWhere((p) => p.id == id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengumuman berhasil dihapus'),
                  backgroundColor: Color(0xFF465940),
                ),
              );
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Ganti semua DateFormat dengan fungsi _formatDate
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  void _showAnnouncementDialog(BuildContext context, bool isEdit, {PengumumanItem? pengumuman}) {
    final judulController = TextEditingController(text: isEdit ? pengumuman?.judul : '');
    final isiController = TextEditingController(text: isEdit ? pengumuman?.isi : '');
    final tujuanController = TextEditingController(text: isEdit ? pengumuman?.tujuan : '');
    DateTime? selectedDate = isEdit ? pengumuman?.tanggal : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isEdit ? 'Edit Pengumuman' : 'Tambah Pengumuman Baru',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF465940),
                  ),
                ),
                const SizedBox(height: 20),
                _buildMobileFormField(judulController, 'Judul Pengumuman'),
                const SizedBox(height: 16),
                _buildMobileFormField(isiController, 'Isi Pengumuman', maxLines: 3),
                const SizedBox(height: 16),
                _buildMobileFormField(tujuanController, 'Tujuan Pengumuman'),
                const SizedBox(height: 16),
                _buildDateField(
                  selectedDate: selectedDate,
                  onDateSelected: (date) {
                    setSheetState(() {
                      selectedDate = date;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF465940),
                          side: const BorderSide(color: Color(0xFF465940)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Batal'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (judulController.text.isEmpty ||
                              isiController.text.isEmpty ||
                              tujuanController.text.isEmpty ||
                              selectedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Semua field harus diisi')),
                            );
                            return;
                          }

                          setState(() {
                            if (isEdit && pengumuman != null) {
                              final index = _pengumumanList.indexWhere((p) => p.id == pengumuman.id);
                              if (index != -1) {
                                _pengumumanList[index] = PengumumanItem(
                                  id: pengumuman.id,
                                  judul: judulController.text,
                                  isi: isiController.text,
                                  tujuan: tujuanController.text,
                                  tanggal: selectedDate!,
                                );
                              }
                            } else {
                              final newId = _pengumumanList.isEmpty
                                  ? 1
                                  : _pengumumanList.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
                              _pengumumanList.add(
                                PengumumanItem(
                                  id: newId,
                                  judul: judulController.text,
                                  isi: isiController.text,
                                  tujuan: tujuanController.text,
                                  tanggal: selectedDate!,
                                ),
                              );
                            }
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEdit ? 'Pengumuman berhasil diedit' : 'Pengumuman berhasil ditambahkan'),
                              backgroundColor: const Color(0xFF465940),
                            ),
                          );
                        },
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
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileFormField(TextEditingController controller, String label, {int maxLines = 1}) {
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
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({DateTime? selectedDate, required Function(DateTime) onDateSelected}) {
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
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  // Di _buildDateField, ganti:
                  // DateFormat('dd-MM-yyyy').format(selectedDate!)
                  // menjadi:
                  selectedDate != null
                      ? _formatDate(selectedDate!)
                      : 'Pilih tanggal',
                  style: TextStyle(
                    color: selectedDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF0),
      appBar: AppBar(
        title: const Text('Pengumuman'),
        backgroundColor: const Color(0xFF465940),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _buildContent(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAnnouncementDialog(context, false);
        },
        backgroundColor: const Color(0xFF465940),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _pengumumanList.map((pengumuman) => _buildAnnouncementCard(pengumuman)).toList(),
      ),
    );
  }

  Widget _buildAnnouncementCard(PengumumanItem pengumuman) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
            const SizedBox(height: 8),
            Text(
              pengumuman.isi,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Tujuan: ${pengumuman.tujuan}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      selectedItemColor: const Color(0xFF465940),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Guru',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Siswa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.announcement),
          label: 'Pengumuman',
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