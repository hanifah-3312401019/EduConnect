import 'package:flutter/material.dart';
import 'package:frontend/orangtua/dashboard_orangtua.dart';
import 'package:frontend/orangtua/jadwal.dart';
import 'package:frontend/orangtua/agenda.dart';
import 'package:frontend/orangtua/pembayaran.dart';
import 'package:frontend/orangtua/profil.dart';
import 'package:frontend/orangtua/perizinan.dart';
import 'package:frontend/orangtua/rekap_ketidakhadiran.dart';

class NavbarOrangtua extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTap; // tambahkan ini

  const NavbarOrangtua({
    super.key,
    required this.selectedIndex,
    this.onTap, // tambahkan di constructor
  });

  static const Color greenColor = Color(0xFF465940);

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF465940);

    return BottomNavigationBar(
      currentIndex: selectedIndex.clamp(0, 4), // ⬅ pakai clamp untuk jaga-jaga
      onTap: onTap,
      backgroundColor: greenColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Halaman Utama'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Agenda'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Jadwal'),
        BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Pembayaran'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}
