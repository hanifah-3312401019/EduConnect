import 'package:flutter/material.dart';
import 'dashboard_orangtua.dart';
import 'jadwal.dart';
import 'pembayaran.dart';
import 'profil.dart';
import 'package:frontend/auth/login.dart';

class PengumumanPage extends StatefulWidget {
  const PengumumanPage({super.key});

  @override
  State<PengumumanPage> createState() => _PengumumanPageState();
}

class _PengumumanPageState extends State<PengumumanPage> {
  int _selectedIndex = 2;

  final List<Map<String, String>> _pengumuman = [
    {
      'judul': 'Libur Hari Raya',
      'tanggal': '18 Juni 2025',
      'deskripsi':
          'Sekolah akan diliburkan dalam rangka perayaan Hari Raya Idul Adha.',
    },
    {
      'judul': 'Pengumpulan Raport',
      'tanggal': '02 September 2025',
      'deskripsi':
          'Pengumpulan raport semester genap akan dilaksanakan di ruang guru mulai pukul 08.00.',
    },
    {
      'judul': 'Hari Pahlawan',
      'tanggal': '10 November 2025',
      'deskripsi':
          'Upacara bendera wajib diikuti oleh seluruh siswa dalam memperingati Hari Pahlawan Nasional.',
    },
    {
      'judul': 'Libur Hari Raya',
      'tanggal': '12 Desember 2025 - 05 Januari 2026',
      'deskripsi':
          'Sekolah libur panjang akhir semester dan tahun baru. Kegiatan belajar mengajar akan dimulai kembali tanggal 6 Januari 2026.',
    },
  ];

  List<bool> _isExpanded = [];

  @override
  void initState() {
    super.initState();
    _isExpanded = List.filled(_pengumuman.length, false);
  }

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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: greenColor),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, color: greenColor),
            const SizedBox(width: 6),
            const Text(
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
            icon: Icon(Icons.notifications_none, color: greenColor),
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
              decoration: BoxDecoration(color: greenColor),
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
            _drawerItem(Icons.calendar_month, "Jadwal", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => JadwalPage()),
              );
            }),
            _drawerItem(Icons.campaign, "Pengumuman", () {}),
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
              const Row(
                children: [
                  Icon(Icons.campaign, color: greenColor),
                  SizedBox(width: 8),
                  Text(
                    "Pengumuman :",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: greenColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._pengumuman.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final expanded = _isExpanded[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded[index] = !_isExpanded[index];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: greenColor,
                      borderRadius: BorderRadius.circular(12),
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
                        Text(
                          item['judul']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['tanggal']!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        if (expanded) ...[
                          const SizedBox(height: 8),
                          Text(
                            item['deskripsi']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
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
