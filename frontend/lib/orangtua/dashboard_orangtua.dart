import 'package:flutter/material.dart';
import 'perizinan.dart';
import 'jadwal.dart';
import 'pengumuman.dart';
import 'pembayaran.dart';
import 'profil.dart';
import 'agenda.dart';
import 'package:frontend/auth/login.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Color greenColor = const Color(0xFF465940);
  final Color backgroundColor = const Color(0xFFFDFBF0);
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => JadwalPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PengumumanPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RincianPembayaranPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilPage()),
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
            _drawerItem(Icons.home, "Permohonan Izin", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PerizinanPage()),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PengumumanPage()),
              );
            }),
            _drawerItem(Icons.payment, "Pembayaran", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RincianPembayaranPage(),
                ),
              );
            }),
            _drawerItem(Icons.person, "Profil", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilPage()),
              );
            }),
            const Divider(),
            _drawerItem(Icons.logout, "Keluar", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            }, color: Colors.red),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAttendanceSection(),
            const SizedBox(height: 24),
            _buildAnnouncementSection(),
            const SizedBox(height: 24),
            _buildScheduleSectionToday(),
            const SizedBox(height: 20),
            _buildScheduleSectionTomorrow(),
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
        iconSize: 22,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Halaman Utama',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
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

  Widget _drawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? greenColor),
      title: Text(title, style: TextStyle(color: color ?? Colors.black87)),
      onTap: onTap,
    );
  }

  Widget _buildAttendanceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: greenColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 3), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Kehadiran Anak",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _attendanceItem(Icons.check_circle, "Hadir", "22"),
              _attendanceItem(Icons.timer, "Izin", "3"),
              _attendanceItem(Icons.cancel, "Alfa", "0"),
              _attendanceItem(Icons.favorite, "Sakit", "2"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _attendanceItem(IconData icon, String title, String count) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Pengumuman",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                "Lihat Semua",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _announcementCard(
          "Rapat Orang Tua Siswa",
          "Jadwal rapat akan dilaksanakan...",
          "5 jam lalu",
        ),
        _announcementCard(
          "Libur Nasional",
          "Sekolah libur pada tanggal...",
          "7 hari lalu",
        ),
      ],
    );
  }

  Widget _announcementCard(String title, String subtitle, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign, color: Color(0xFF465940), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildScheduleSectionToday() {
    return _scheduleSection(
      title: "Jadwal Hari Ini",
      buttonText: "Kalender",
      items: const [
        ["Matematika", "08:00 - 08:45"],
        ["Bahasa Indonesia", "08:45 - 09:30"],
        ["Olahraga", "10:00 - 10:45"],
        ["Agama", "10:45 - 11:30"],
      ],
    );
  }

  Widget _buildScheduleSectionTomorrow() {
    return _scheduleSection(
      title: "Jadwal Besok",
      buttonText: "Lihat Selengkapnya",
      items: const [
        ["Biologi", "08:00 - 08:45"],
        ["Bahasa Inggris", "08:45 - 09:30"],
      ],
    );
  }

  Widget _scheduleSection({
    required String title,
    required String buttonText,
    required List<List<String>> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                buttonText,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: greenColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            children: items.map((e) => _scheduleItem(e[0], e[1])).toList(),
          ),
        ),
      ],
    );
  }

  Widget _scheduleItem(String subject, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            subject,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
