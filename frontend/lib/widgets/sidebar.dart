import 'package:flutter/material.dart';
import '../guru/permohonan_izin.dart';
import '../guru/absensi.dart';
import '../guru/pengumuman.dart' as guru_pengumuman; // Tambahkan alias
import '../guru/agenda.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Drawer(
      width: isMobile ? 280 : 280,
      backgroundColor: const Color(0xFF465940),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildProfileSection(isMobile),
            const SizedBox(height: 20),

            // Navigation Menu
            _buildNavigationMenu(context, isMobile),
            const Spacer(),

            // Logout Button
            _buildLogoutButton(context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: isMobile ? 25 : 30,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person,
            size: isMobile ? 25 : 30,
            color: const Color(0xFF465940),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Siti Nursiah',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationMenu(BuildContext context, bool isMobile) {
    return Column(
      children: [
        _buildMenuTile(context, 'Halaman Utama', Icons.home, () {
          Navigator.pushReplacementNamed(context, '/guru/dashboard');
        }, isMobile),
        _buildMenuTile(context, 'Absensi', Icons.people, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Absensi()),
          );
        }, isMobile),
        _buildMenuTile(context, 'Agenda', Icons.calendar_today, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Agenda()),
          );
        }, isMobile),
        _buildMenuTile(context, 'Pengumuman', Icons.announcement, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const guru_pengumuman.PengumumanPage()), // Gunakan alias
          );
        }, isMobile),
        _buildMenuTile(context, 'Permohonan Izin', Icons.assignment, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PermohonanIzin()),
          );
        }, isMobile),
      ],
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isMobile,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: isMobile ? 18 : 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? 13 : 14,
        ),
      ),
      onTap: () {
        // Tutup drawer dulu
        Navigator.pop(context);
        // Jalankan aksi navigasi
        onTap();
      },
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 0,
      dense: isMobile,
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isMobile) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Tutup drawer
          Navigator.pop(context);
          // Navigasi ke login
          Navigator.pushReplacementNamed(context, '/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF465940),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 10 : 12,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Keluar',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Fitur akan segera hadir'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}