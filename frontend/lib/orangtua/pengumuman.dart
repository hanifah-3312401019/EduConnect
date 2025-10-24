import 'package:flutter/material.dart';
import 'dashboard_orangtua.dart';
import 'perizinan.dart';
import 'jadwal.dart';
import 'pembayaran.dart';
import 'profil.dart';
import 'agenda.dart';
import 'package:frontend/auth/login.dart';

class PengumumanPage extends StatefulWidget {
  const PengumumanPage({super.key});

  @override
  State<PengumumanPage> createState() => _PengumumanPageState();
}

class _PengumumanPageState extends State<PengumumanPage> {
  int _selectedIndex = 2;
  String _selectedKategori = 'Semua';

  final List<String> _kategoriList = ['Semua', 'Umum', 'Kelas', 'Personal'];

  final List<Map<String, String>> _pengumuman = [
    {
      'judul': 'Libur Nasional',
      'kategori': 'Umum',
      'deskripsi':
          'Setelah siswa mengikuti ujian sekolah, maka pembelajaran akan diliburkan dari tanggal 25 Desember 2025 - 25 Januari 2025',
    },
    {
      'judul': 'Ujian Akhir Semester',
      'kategori': 'Kelas',
      'deskripsi':
          'Siswa kelas 5 akan mengikuti ujian sesuai dengan jadwal, oleh karena itu siswa diminta untuk membawa kartu ujian yang sudah diberikan.',
    },
    {
      'judul': 'Informasi Pembayaran',
      'kategori': 'Personal',
      'deskripsi':
          'Mohon segera melunasi pembayaran SPP sesuai dengan rincian pembayaran yang dapat dilihat pada halaman pembayaran dibawah ini.',
    },
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget? targetPage;
    switch (index) {
      case 0:
        targetPage = DashboardPage();
        break;
      case 1:
        targetPage = JadwalPage();
        break;
      case 2:
        break;
      case 3:
        targetPage = RincianPembayaranPage();
        break;
      case 4:
        targetPage = ProfilPage();
        break;
    }
    if (targetPage != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetPage!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF465940);
    const Color backgroundColor = Color(0xFFFDFBF0);

    final filteredList = _selectedKategori == 'Semua'
        ? _pengumuman
        : _pengumuman
            .where((item) => item['kategori'] == _selectedKategori)
            .toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: greenColor),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.school, color: greenColor),
            SizedBox(width: 6),
            Text(
              "EduConnect",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: greenColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak ada notifikasi baru')),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black12, height: 1.0),
        ),
      ),
      drawer: Drawer(
        backgroundColor: backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: greenColor),
              child: const Center(
                child: Text(
                  "EduConnect Menu",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            _drawerItem(Icons.home, "Halaman Utama", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => DashboardPage()),
              );
            }),
            _drawerItem(Icons.home, "Permohonan Izin", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PerizinanPage()),
              );
            }),
            _drawerItem(Icons.calendar_month, "Jadwal", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => JadwalPage()),
              );
            }),
            _drawerItem(Icons.event_note, "Agenda", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AgendaPage()),
                );
              }),
            _drawerItem(Icons.campaign, "Pengumuman", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PengumumanPage()),
              );
            }),
            _drawerItem(Icons.payment, "Pembayaran", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => RincianPembayaranPage()),
              );
            }),
            _drawerItem(Icons.person, "Profil", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ProfilPage()),
              );
            }),
            const Divider(),
            _drawerItem(Icons.logout, "Keluar", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            }, color: Colors.red),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.campaign, color: greenColor),
                  const SizedBox(width: 8),
                  const Text(
                    "Pengumuman :",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: greenColor,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: greenColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedKategori,
                        dropdownColor: greenColor,
                        icon:
                            const Icon(Icons.arrow_drop_down, color: Colors.white),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        items: _kategoriList.map((String kategori) {
                          return DropdownMenuItem<String>(
                            value: kategori,
                            child: Text(kategori),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedKategori = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  key: ValueKey<String>(_selectedKategori),
                  children: filteredList.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: greenColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item['judul']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDFBF0),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item['kategori']!,
                                  style: const TextStyle(
                                    color: greenColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['deskripsi']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: greenColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Halaman Utama',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Pengumuman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Pembayaran',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF465940)),
      title: Text(title, style: TextStyle(color: color ?? Colors.black87)),
      onTap: onTap,
    );
  }
}
