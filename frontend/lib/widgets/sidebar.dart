import 'package:flutter/material.dart';
import '../guru/permohonan_izin.dart';
import '../guru/absensi.dart';
import '../guru/pengumuman.dart';
import '../guru/agenda.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: const Color(0xFF465940),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildProfileSection(),
            const SizedBox(height: 20),

            // Navigation Menu
            _buildNavigationMenu(context),
            const Spacer(),

            // Logout Button
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 30, color: Color(0xFF465940)),
        ),
        SizedBox(height: 12),
        Text(
          'Siti Nursiah',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationMenu(BuildContext context) {
    return Column(
      children: [
        _buildMenuTile(context, 'Halaman Utama', Icons.home, () {
          Navigator.pushReplacementNamed(context, '/guru/dashboard');
        }),
        _buildMenuTile(context, 'Absensi', Icons.people, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Absensi()),
          );
        }),
        _buildMenuTile(context, 'Agenda', Icons.calendar_today, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Agenda()),
          );
        }),

        _buildMenuTile(context, 'Pengumuman', Icons.announcement, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Pengumuman()),
          );
        }),
        _buildMenuTile(context, 'Permohonan Izin', Icons.assignment, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PermohonanIzin()),
          );
        }),
      ],
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 20),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      onTap: () {
        // Tutup drawer dulu
        Navigator.pop(context);
        // Jalankan aksi navigasi
        onTap();
      },
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 0,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text('Keluar'),
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
