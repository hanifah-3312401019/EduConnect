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
  const sidebarOrangtua({super.key});

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
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),

          _drawerItem(context, Icons.home, "Halaman Utama", DashboardPage()),
          _drawerItem(context, Icons.home, "Permohonan Izin", PerizinanPage()),
          _drawerItem(context, Icons.calendar_month, "Jadwal", JadwalPage()),
          _drawerItem(context, Icons.event_note, "Agenda", AgendaPage()),
          _drawerItem(context, Icons.campaign, "Pengumuman", PengumumanPage()),
          _drawerItem(context, Icons.payment, "Pembayaran", RincianPembayaranPage()),
          _drawerItem(context, Icons.person, "Profil", ProfilPage()),

          const Divider(),

          _drawerItem(context, Icons.logout, "Keluar", LoginPage(), color: Colors.red),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget targetPage, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? greenColor),
      title: Text(title, style: TextStyle(color: color ?? Colors.black87)),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => targetPage),
        );
      },
    );
  }
}
