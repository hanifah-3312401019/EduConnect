import 'package:flutter/material.dart';
import '../guru/absensi.dart';
import '../guru/agenda.dart';
import '../guru/pengumuman.dart' as guru_pengumuman; // Tambahkan alias

class NavigationBarGuru extends StatefulWidget {
  const NavigationBarGuru({super.key});

  @override
  State<NavigationBarGuru> createState() => _NavigationBarGuruState();
}

class _NavigationBarGuruState extends State<NavigationBarGuru> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PlaceholderWidget(title: 'Halaman Utama', icon: Icons.home),
    const Absensi(),
    const Agenda(),
    const guru_pengumuman.PengumumanPage(), // Gunakan alias
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
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
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF465940),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Halaman Utama',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Absensi'),
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
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderWidget({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF465940),
        title: Text(title),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: const Color(0xFF465940)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF465940),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Halaman $title Guru',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}