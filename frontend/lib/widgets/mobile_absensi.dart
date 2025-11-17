import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MobileAbsensi extends StatefulWidget {
  const MobileAbsensi({super.key});

  @override
  State<MobileAbsensi> createState() => _MobileAbsensiState();
}

class _MobileAbsensiState extends State<MobileAbsensi> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _siswaList = [];
  bool _selectAllHadir = false;

  @override
  void initState() {
    super.initState();
    _initializeSiswaData();
  }

  void _initializeSiswaData() {
    _siswaList = [
      {'nama': 'Siti Nurhalis', 'hadir': false, 'izin': false, 'sakit': false},
      {'nama': 'Farhan Abas', 'hadir': false, 'izin': false, 'sakit': false},
      {'nama': 'Rafi Ahmad', 'hadir': false, 'izin': false, 'sakit': false},
      {'nama': 'Anmay Musa', 'hadir': false, 'izin': false, 'sakit': false},
      {'nama': 'Rasya Likhan', 'hadir': false, 'izin': false, 'sakit': false},
      {'nama': 'Yogi Yaya', 'hadir': false, 'izin': false, 'sakit': false},
      {'nama': 'Yupis Yupi', 'hadir': false, 'izin': false, 'sakit': false},
    ];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _toggleAllHadir(bool value) {
    setState(() {
      _selectAllHadir = value;
      for (var siswa in _siswaList) {
        siswa['hadir'] = value;
        if (value) {
          siswa['izin'] = false;
          siswa['sakit'] = false;
        }
      }
    });
  }

  void _updateSiswaStatus(int index, String type, bool value) {
    setState(() {
      _siswaList[index]['hadir'] = false;
      _siswaList[index]['izin'] = false;
      _siswaList[index]['sakit'] = false;

      _siswaList[index][type] = value;
      _updateSelectAllStatus();
    });
  }

  void _updateSelectAllStatus() {
    bool allHadir = _siswaList.every((s) => s['hadir']);
    setState(() => _selectAllHadir = allHadir);
  }

  void _simpanAbsensi() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Absensi tanggal ${_formatDate(_selectedDate)} berhasil disimpan',
        ),
        backgroundColor: const Color(0xFF465940),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Date picker & "Centang Semua Hadir"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_today),
                label: Text(_formatDate(_selectedDate)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF465940),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _selectAllHadir,
                    onChanged: (value) => _toggleAllHadir(value ?? false),
                    activeColor: const Color(0xFF465940),
                  ),
                  const Text("Centang Semua Hadir"),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // List siswa
          Expanded(
            child: ListView.builder(
              itemCount: _siswaList.length,
              itemBuilder: (context, index) {
                final siswa = _siswaList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          siswa['nama'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2F3B1F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatusCheckbox(
                              siswa,
                              index,
                              'hadir',
                              Colors.green,
                            ),
                            _buildStatusCheckbox(
                              siswa,
                              index,
                              'izin',
                              Colors.blue,
                            ),
                            _buildStatusCheckbox(
                              siswa,
                              index,
                              'sakit',
                              Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Simpan button
          ElevatedButton.icon(
            onPressed: _simpanAbsensi,
            icon: const Icon(Icons.save),
            label: const Text("Simpan Absensi"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF465940),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCheckbox(
    Map<String, dynamic> siswa,
    int index,
    String type,
    Color color,
  ) {
    return Row(
      children: [
        Checkbox(
          value: siswa[type],
          onChanged: (value) => _updateSiswaStatus(index, type, value ?? false),
          activeColor: color,
        ),
        Text(type.toUpperCase()),
      ],
    );
  }
}
