import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/sidebar.dart';

class Absensi extends StatelessWidget {
  const Absensi({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return const MobileAbsensiWithNav();
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFDFBF0),
          appBar: AppBar(
            title: const Text('Absensi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            backgroundColor: const Color(0xFF465940),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          drawer: const Sidebar(),
          body: const SafeArea(child: WebAbsensi()),
        );
      },
    );
  }
}

class MobileAbsensiWithNav extends StatefulWidget {
  const MobileAbsensiWithNav({super.key});

  @override
  State<MobileAbsensiWithNav> createState() => _MobileAbsensiWithNavState();
}

class _MobileAbsensiWithNavState extends State<MobileAbsensiWithNav> {
  int _currentIndex = 1; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF0),
      appBar: AppBar(
        title: const Text('Absensi', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF465940),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const Sidebar(),
      body: const SafeArea(child: MobileAbsensiContent()),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/guru/dashboard');
              break;
            case 1:
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/guru/agenda');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/guru/pengumuman');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF465940),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Utama',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Absensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Pengumuman',
          ),
        ],
      ),
    );
  }
}

class MobileAbsensiContent extends StatefulWidget {
  const MobileAbsensiContent({super.key});

  @override
  State<MobileAbsensiContent> createState() => _MobileAbsensiContentState();
}

class _MobileAbsensiContentState extends State<MobileAbsensiContent> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _siswaList = [];
  bool _selectAllHadir = false;

  @override
  void initState() {
    super.initState();
    _initializeSiswaData();
  }

  void _initializeSiswaData() {
    _siswaList = List.generate(20, (index) => {
      'nama': 'Siswa ${index + 1}',
      'hadir': false, 'izin': false, 'sakit': false
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

  void _toggleAllHadir(bool value) {
    setState(() {
      _selectAllHadir = value;
      for (var siswa in _siswaList) {
        siswa['hadir'] = value;
        if (value) { siswa['izin'] = false; siswa['sakit'] = false; }
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
    setState(() => _selectAllHadir = _siswaList.every((s) => s['hadir']));
  }

  void _simpanAbsensi() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Absensi tanggal ${DateFormat('dd-MM-yyyy').format(_selectedDate)} berhasil disimpan'),
        backgroundColor: const Color(0xFF465940), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildCheckbox(bool value, Function(bool?) onChanged, Color color, bool isSmallScreen) {
    return Center(
      child: Transform.scale(
        scale: isSmallScreen ? 1.3 : 1.4,
        child: Checkbox(value: value, onChanged: onChanged, activeColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Column(children: [
        Container(
          width: double.infinity, padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF465940), Color(0xFF2D3A2A)]),
            borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Absensi Kelas 1A', style: TextStyle(fontSize: isSmallScreen ? 20 : 24, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: isSmallScreen ? 4 : 8),
            Text('Kelola kehadiran siswa dengan mudah', style: TextStyle(fontSize: isSmallScreen ? 12 : 14, color: Colors.white70)),
          ]),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),

        Container(
          width: double.infinity, padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Icon(Icons.calendar_today, color: const Color(0xFF465940), size: isSmallScreen ? 20 : 24),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Text('Tanggal:', style: TextStyle(fontSize: isSmallScreen ? 16 : 18, fontWeight: FontWeight.bold, color: const Color(0xFF465940))),
            ]),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF465940), foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 20, vertical: isSmallScreen ? 10 : 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(DateFormat('dd-MM-yyyy').format(_selectedDate), style: TextStyle(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.bold)),
                SizedBox(width: isSmallScreen ? 4 : 8), Icon(Icons.edit, size: isSmallScreen ? 14 : 16),
              ]),
            ),
          ]),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Transform.scale(scale: isSmallScreen ? 1.2 : 1.3, child: Checkbox(value: _selectAllHadir, onChanged: (v) => _toggleAllHadir(v ?? false), activeColor: const Color(0xFF465940))),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Text("Centang Semua Hadir", style: TextStyle(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.w600, color: const Color(0xFF465940))),
          ]),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),

        Container(
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF465940), Color(0xFF2D3A2A)])),
              child: Row(children: [
                Expanded(flex: 2, child: Text('Nama Siswa', style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Hadir', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Izin', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Sakit', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.bold))),
              ]),
            ),
            
            ..._siswaList.asMap().entries.map((entry) {
              final index = entry.key;
              final siswa = entry.value;
              return Container(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.white : Colors.grey.shade50,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: index < _siswaList.length - 1 ? 1 : 0)),
                ),
                child: Row(children: [
                  Expanded(flex: 2, child: Text(siswa['nama'], style: TextStyle(fontSize: isSmallScreen ? 12 : 14, fontWeight: FontWeight.w600, color: const Color(0xFF465940)))),
                  Expanded(child: _buildCheckbox(siswa['hadir'], (v) => _updateSiswaStatus(index, 'hadir', v ?? false), Colors.green, isSmallScreen)),
                  Expanded(child: _buildCheckbox(siswa['izin'], (v) => _updateSiswaStatus(index, 'izin', v ?? false), Colors.blue, isSmallScreen)),
                  Expanded(child: _buildCheckbox(siswa['sakit'], (v) => _updateSiswaStatus(index, 'sakit', v ?? false), Colors.orange, isSmallScreen)),
                ]),
              );
            }),
          ]),
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _simpanAbsensi,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF465940), foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: isSmallScreen ? 14 : 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.save, size: isSmallScreen ? 18 : 20), SizedBox(width: isSmallScreen ? 8 : 12),
              Text("Simpan Absensi", style: TextStyle(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 20), // Extra space for scrolling
      ]),
    );
  }
}

// Web Version - DIPERBAIKI agar bisa scroll full
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
    _siswaList = List.generate(25, (index) => {
      'nama': 'Siswa ${index + 1}',
      'hadir': false, 'izin': false, 'sakit': false
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
  }

  void _toggleAllHadir(bool value) {
    setState(() {
      _selectAllHadir = value;
      for (var siswa in _siswaList) {
        siswa['hadir'] = value;
        if (value) { siswa['izin'] = false; siswa['sakit'] = false; }
      }
    });
  }

  void _updateSiswaStatus(int index, String type, bool value) {
    setState(() {
      _siswaList[index]['hadir'] = false; _siswaList[index]['izin'] = false; _siswaList[index]['sakit'] = false;
      _siswaList[index][type] = value;
      _updateSelectAllStatus();
    });
  }

  void _updateSelectAllStatus() {
    setState(() => _selectAllHadir = _siswaList.every((s) => s['hadir']));
  }

  void _simpanAbsensi() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Absensi tanggal ${DateFormat('dd-MM-yyyy').format(_selectedDate)} berhasil disimpan'),
        backgroundColor: const Color(0xFF465940), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF465940), Color(0xFF2D3A2A)]),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Absensi Kelas 1A', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
                SizedBox(height: 8),
                Text('Kelola kehadiran siswa dengan mudah', style: TextStyle(fontSize: 16, color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 32),
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
          const SizedBox(height: 40), // Extra space for scrolling
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.calendar_month_rounded, color: Color(0xFF465940), size: 24),
            SizedBox(width: 12),
            Text('Pilih Tanggal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF465940))),
          ]),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [const Color(0xFF465940).withOpacity(0.1), const Color(0xFF465940).withOpacity(0.05)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF465940).withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  DateFormat('dd-MM-yyyy').format(_selectedDate),
                  style: const TextStyle(color: Color(0xFF465940), fontSize: 20, fontWeight: FontWeight.bold),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.checklist_rounded, color: Color(0xFF465940), size: 24),
            SizedBox(width: 12),
            Text('Aksi Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF465940))),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Transform.scale(
              scale: 1.3,
              child: Checkbox(
                value: _selectAllHadir,
                onChanged: (v) => _toggleAllHadir(v ?? false),
                activeColor: const Color(0xFF465940),
              ),
            ),
            const SizedBox(width: 16),
            const Text('Centang Semua Hadir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF465940))),
          ]),
        ],
      ),
    );
  }

  Widget _buildSiswaTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF465940), Color(0xFF2D3A2A)]),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: const Row(children: [
            Expanded(flex: 2, child: Text('Nama Siswa', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
            Expanded(child: Text('Hadir', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
            Expanded(child: Text('Izin', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
            Expanded(child: Text('Sakit', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
          ]),
        ),
        ..._siswaList.asMap().entries.map((entry) {
          final index = entry.key;
          final siswa = entry.value;
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: index.isEven ? Colors.white : Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: index < _siswaList.length - 1 ? 1 : 0)),
            ),
            child: Row(children: [
              Expanded(flex: 2, child: Text(siswa['nama'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF465940)))),
              Expanded(child: _buildCheckbox(siswa['hadir'], (v) => _updateSiswaStatus(index, 'hadir', v ?? false), Colors.green)),
              Expanded(child: _buildCheckbox(siswa['izin'], (v) => _updateSiswaStatus(index, 'izin', v ?? false), Colors.blue)),
              Expanded(child: _buildCheckbox(siswa['sakit'], (v) => _updateSiswaStatus(index, 'sakit', v ?? false), Colors.orange)),
            ]),
          );
        }),
      ]),
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
      child: ElevatedButton(
        onPressed: _simpanAbsensi,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF465940),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.save_rounded, size: 24),
            SizedBox(width: 12),
            Text('Simpan Absensi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}