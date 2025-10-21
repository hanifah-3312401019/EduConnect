import 'package:flutter/material.dart';
import 'dashboard_orangtua.dart';
import 'package:frontend/auth/login.dart';
import 'pengumuman.dart';
import 'pembayaran.dart';
import 'profil.dart';
import 'agenda.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final Color greenColor = const Color(0xFF465940);
  final Color backgroundColor = const Color(0xFFFDFBF0);
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardPage()),
        );
        break;
      case 1:
        break; // tetap di Jadwal
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PengumumanPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RincianPembayaranPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfilPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Container(color: Colors.black.withOpacity(0.2), height: 1.0),
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
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            }),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHari("Hari Senin", [
              ["Matematika", "08:00–08:45"],
              ["Bahasa Indonesia", "08:45–09:30"],
              ["Olahraga", "10:00–10:45"],
              ["Agama", "10:45–11:30"],
            ]),
            _buildHari("Hari Selasa", [
              ["Bahasa Inggris", "08:00–08:45"],
              ["Mandarin", "08:45–09:30"],
              ["Pendidikan Pancasila", "10:00–10:45"],
              ["Seni Budaya", "10:45–11:30"],
            ]),
            _buildHari("Hari Rabu", [
              ["Ilmu Pengetahuan Alam", "08:00–08:45"],
              ["Ilmu Pengetahuan Sosial", "08:45–09:30"],
              ["Matematika", "10:00–10:45"],
            ]),
            _buildHari("Hari Kamis", [
              ["Bahasa Indonesia", "08:00–08:45"],
              ["Agama", "08:45–09:30"],
              ["PJOK", "10:00–10:45"],
              ["Seni Musik", "10:45–11:30"],
            ]),
            _buildHari("Hari Jumat", [
              ["Bahasa Inggris", "07:30–08:15"],
              ["Prakarya", "08:15–09:00"],
              ["Matematika", "09:30–10:15"],
            ]),
            const SizedBox(height: 80),
          ],
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

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: greenColor),
      title: Text(title, style: const TextStyle(color: Colors.black87)),
      onTap: onTap,
    );
  }

  Widget _buildHari(String hari, List<List<String>> jadwal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$hari :",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: greenColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: greenColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              children: jadwal.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        item[1],
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
