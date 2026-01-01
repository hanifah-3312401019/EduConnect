import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../guru/permohonan_izin.dart';
import '../guru/pengumuman.dart' as guru_pengumuman;
import '../guru/agenda.dart';
import '../guru/dashboard_guru.dart';

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
      width: isMobile ? 280 : 320, // Lebih lebar untuk desktop
      backgroundColor: const Color(0xFF465940),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 24), // Padding lebih besar untuk desktop
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(isMobile),
              SizedBox(height: isMobile ? 20 : 30), // Spacing lebih besar untuk desktop
              Expanded(
                child: _buildNavigationMenu(context, isMobile),
              ),
              _buildLogoutButton(context, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: isMobile ? 25 : 32, // Lebih besar untuk desktop
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person,
            size: isMobile ? 25 : 32,
            color: const Color(0xFF465940),
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16), // Spacing lebih besar untuk desktop
        Text(
          namaGuru,
          style: TextStyle(
            fontSize: isMobile ? 14 : 18, // Font lebih besar untuk desktop
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isMobile ? 4 : 8),
        Text(
          'Guru',
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationMenu(BuildContext context, bool isMobile) {
    // Mendapatkan route saat ini untuk menentukan menu aktif
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMenuTile(
          context: context,
          title: 'Halaman Utama',
          icon: Icons.home,
          isActive: currentRoute == '/guru/dashboard',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/guru/dashboard');
          },
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 8 : 12), // Spacing lebih besar untuk desktop
        
        _buildMenuTile(
          context: context,
          title: 'Agenda',
          icon: Icons.calendar_today,
          isActive: currentRoute == '/guru/agenda',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/guru/agenda');
          },
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 8 : 12),
        
        _buildMenuTile(
          context: context,
          title: 'Pengumuman',
          icon: Icons.announcement,
          isActive: currentRoute == '/guru/pengumuman',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/guru/pengumuman');
          },
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 8 : 12),
        
        _buildMenuTile(
          context: context,
          title: 'Permohonan Izin',
          icon: Icons.assignment,
          isActive: currentRoute == '/guru/permohonan-izin',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/guru/permohonan-izin');
          },
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return Material(
      color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 14 : 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: isMobile ? 18 : 22, // Ikon lebih besar untuk desktop
              ),
              SizedBox(width: isMobile ? 12 : 16), // Spacing lebih besar untuk desktop
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 13 : 16, // Font lebih besar untuk desktop
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (isActive)
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.7),
                  size: isMobile ? 16 : 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isMobile) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          // Konfirmasi logout untuk UX yang lebih baik
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Konfirmasi Logout',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Apakah Anda yakin ingin keluar?',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Batal', style: TextStyle(fontSize: isMobile ? 14 : 16)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF465940),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Logout', style: TextStyle(fontSize: isMobile ? 14 : 16)),
                ),
              ],
            ),
          );

          if (shouldLogout == true) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();

            // Tutup drawer sebelum navigasi
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF465940),
          padding: EdgeInsets.symmetric(
            vertical: isMobile ? 12 : 16, // Padding lebih tinggi untuk desktop
            horizontal: isMobile ? 16 : 24, // Padding lebih lebar untuk desktop
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 8 : 10), // Border radius responsive
          ),
          elevation: 0,
        ),
        child: Text(
          'Keluar',
          style: TextStyle(
            fontSize: isMobile ? 14 : 17, // Font lebih besar untuk desktop
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}