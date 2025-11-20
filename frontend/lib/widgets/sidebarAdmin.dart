import 'package:flutter/material.dart';

class SidebarAdmin extends StatelessWidget {
  final Function(String) onMenuSelected;

  const SidebarAdmin({super.key, required this.onMenuSelected});

  static const Color greenColor = Color(0xFF465940);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: greenColor,
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ======= HEADER =======
          const Text(
            "Admin Menu",
            style: TextStyle(
              color: Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // ======= LIST MENU =======
          Expanded(
            child: ListView(
              children: [
                menuItem(Icons.dashboard, "Dashboard"),
                menuItem(Icons.person, "Data Guru"),
                menuItem(Icons.school, "Data Siswa"),
                menuItem(Icons.family_restroom, "Data Orang Tua"),
                menuItem(Icons.class_, "Data Kelas"),
                menuItem(Icons.calendar_view_week, "Jadwal Pelajaran"),
                menuItem(Icons.calendar_view_week, "informasi_pembayaran"),

                const Divider(color: Colors.white54, height: 30),

                menuItem(Icons.logout, "Keluar", color: Colors.redAccent),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget menuItem(IconData icon, String title, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.white,
          fontSize: 15,
        ),
      ),
      onTap: () => onMenuSelected(title),
      hoverColor: Colors.white10, // biar ada efek hover
    );
  }
}
