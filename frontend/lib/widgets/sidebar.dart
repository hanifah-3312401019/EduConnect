import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../guru/permohonan_izin.dart';
import '../guru/absensi.dart';
import '../guru/pengumuman.dart' as guru_pengumuman;
import '../guru/agenda.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String namaGuru = "Guru";

  @override
  void initState() {
    super.initState();
    _loadGuruData();
  }

  Future<void> _loadGuruData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      namaGuru = prefs.getString('Guru_Nama') ?? "Guru";
    });
  }

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
            _buildProfileSection(isMobile),
            const SizedBox(height: 20),
            _buildNavigationMenu(context, isMobile),
            const Spacer(),
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
          namaGuru, // <- sudah otomatis
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
          Navigator.push(context, MaterialPageRoute(builder: (_) => const Absensi()));
        }, isMobile),
        _buildMenuTile(context, 'Agenda', Icons.calendar_today, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const Agenda()));
        }, isMobile),
        _buildMenuTile(context, 'Pengumuman', Icons.announcement, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const guru_pengumuman.PengumumanPage()),
          );
        }, isMobile),
        _buildMenuTile(context, 'Permohonan Izin', Icons.assignment, () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PermohonanIzin()));
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
      leading: Icon(icon, color: Colors.white, size: isMobile ? 18 : 20),
      title: Text(title, style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14)),
      onTap: () {
        Navigator.pop(context);
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
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/login');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF465940),
          padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('Keluar', style: TextStyle(fontSize: isMobile ? 14 : 16)),
      ),
    );
  }
}
