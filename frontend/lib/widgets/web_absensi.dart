import 'package:flutter/material.dart';

class WebAbsensi extends StatefulWidget {
  const WebAbsensi({super.key});

  @override
  State<WebAbsensi> createState() => _WebAbsensiState();
}

class _WebAbsensiState extends State<WebAbsensi> {
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
      setState(() {
        _selectedDate = picked;
      });
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
    bool allHadir = true;
    for (var siswa in _siswaList) {
      if (!siswa['hadir']) {
        allHadir = false;
        break;
      }
    }
    setState(() {
      _selectAllHadir = allHadir;
    });
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
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFFDFBF0), Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDatePicker()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildSelectAll()),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSiswaTable(),
                  const SizedBox(height: 32),
                  _buildSimpanButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [const Color(0xFF465940), const Color(0xFF2D3A2A)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'EduConnect',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Absensi Kelas 1A - Kelola kehadiran siswa dengan mudah',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: Color(0xFF465940),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Pilih Tanggal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF465940),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF465940).withOpacity(0.1),
                    const Color(0xFF465940).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF465940).withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Text(
                  _formatDate(_selectedDate),
                  style: const TextStyle(
                    color: Color(0xFF465940),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectAll() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.checklist_rounded, color: Color(0xFF465940), size: 24),
              SizedBox(width: 12),
              Text(
                'Aksi Cepat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF465940),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Transform.scale(
                scale: 1.3,
                child: Checkbox(
                  value: _selectAllHadir,
                  onChanged: (value) => _toggleAllHadir(value ?? false),
                  activeColor: const Color(0xFF465940),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Centang Semua Hadir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF465940),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [const Color(0xFF465940), const Color(0xFF2D3A2A)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Nama Siswa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Hadir',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Izin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Sakit',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ..._siswaList.asMap().entries.map((entry) {
            final index = entry.key;
            final siswa = entry.value;
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: index.isEven ? Colors.white : Colors.grey.shade50,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: index < _siswaList.length - 1 ? 1 : 0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      siswa['nama'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF465940),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildCheckbox(
                      siswa['hadir'],
                      (v) => _updateSiswaStatus(index, 'hadir', v ?? false),
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildCheckbox(
                      siswa['izin'],
                      (v) => _updateSiswaStatus(index, 'izin', v ?? false),
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildCheckbox(
                      siswa['sakit'],
                      (v) => _updateSiswaStatus(index, 'sakit', v ?? false),
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCheckbox(bool value, Function(bool?) onChanged, Color color) {
    return Center(
      child: Transform.scale(
        scale: 1.4,
        child: Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Widget _buildSimpanButton() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF465940).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _simpanAbsensi,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF465940),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.save_rounded, size: 24),
              SizedBox(width: 12),
              Text(
                'Simpan Absensi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
