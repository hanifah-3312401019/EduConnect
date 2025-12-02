import 'package:flutter/material.dart';
import 'package:frontend/orangtua/dashboard_orangtua.dart';
import 'package:frontend/orangtua/perizinan.dart';
import 'package:frontend/orangtua/jadwal.dart';
import 'package:frontend/orangtua/agenda.dart';
import 'package:frontend/orangtua/pengumuman.dart';
import 'package:frontend/orangtua/pembayaran.dart';
import 'package:frontend/orangtua/profil.dart';
import 'package:frontend/auth/login.dart';

class sidebarOrangtua extends StatelessWidget {
  final int currentIndex; // untuk highlight menu aktif
  const sidebarOrangtua({super.key, this.currentIndex = 0});

  static const Color greenColor = Color(0xFF465940);
  static const Color backgroundColor = Color(0xFFFDFBF0);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: backgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: greenColor),
            child: Center(
              child: Text(
                "EduConnect Menu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          _drawerItem(
            context,
            icon: Icons.home,
            title: "Halaman Utama",
            targetPage: DashboardPage(),
            index: 0,
          ),
          _drawerItem(
            context,
            icon: Icons.assignment,
            title: "Permohonan Izin",
            targetPage: PerizinanPage(),
            index: 1,
          ),
          _drawerItem(
            context,
            icon: Icons.calendar_month,
            title: "Jadwal",
            targetPage: JadwalPage(),
            index: 2,
          ),
          _drawerItem(
            context,
            icon: Icons.event_note,
            title: "Agenda",
            targetPage: AgendaPage(),
            index: 3,
          ),
          _drawerItem(
            context,
            icon: Icons.campaign,
            title: "Pengumuman",
            targetPage: PengumumanPage(),
            index: 4,
          ),
          _drawerItem(
            context,
            icon: Icons.payment,
            title: "Pembayaran",
            targetPage: RincianPembayaranPage(),
            index: 5,
          ),
          _drawerItem(
            context,
            icon: Icons.person,
            title: "Profil",
            targetPage: ProfilPage(),
            index: 6,
          ),

          const Divider(),

          _drawerItem(
            context,
            icon: Icons.logout,
            title: "Keluar",
            targetPage: LoginPage(),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget targetPage,
    int? index,
    Color? color,
  }) {
    final bool isSelected = (index != null && index == currentIndex);
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? greenColor : color ?? Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? greenColor : color ?? Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // tutup drawer
        if (!isSelected) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => targetPage),
          );
        }
      },
    );
  }
}
