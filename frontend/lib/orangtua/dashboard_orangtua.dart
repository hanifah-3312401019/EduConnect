import 'package:flutter/material.dart';
import 'jadwal.dart';
import 'pembayaran.dart'; 
import 'pengumuman.dart';
import 'profil.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Color greenColor = const Color(0xFF465940);
  final Color backgroundColor = const Color(0xFFFDFBF0);
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigasi ke halaman sesuai tab
    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JadwalPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PengumumanPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RincianPembayaranPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilPage()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigasi ke tab ${index + 1}'),
            duration: const Duration(milliseconds: 800),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const Icon(Icons.menu, color: Colors.black87),
        title: Row(
          children: [
            Icon(Icons.school, color: greenColor),
            const SizedBox(width: 8),
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
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tidak ada notifikasi baru')),
              );
            },
          ),
        ],
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
            _buildScheduleSection(),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Halaman Utama'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Jadwal'),
          BottomNavigationBarItem(icon: Icon(Icons.announcement), label: 'Pengumuman'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Pembayaran'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
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
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _attendanceItem(Icons.check_circle, "Hadir", "22", Colors.white),
              _attendanceItem(Icons.timer, "Izin", "3", Colors.white),
              _attendanceItem(Icons.cancel, "Alfa", "0", Colors.white),
              _attendanceItem(Icons.favorite, "Sakit", "2", Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Pengumuman", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PengumumanPage()),
                );
              },
              child: Text("Lihat Semua", style: TextStyle(color: Colors.grey[600])),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _announcementCard("Rapat Orang Tua Siswa", "Jadwal rapat akan dilaksanakan...", "5 jam lalu"),
        _announcementCard("Libur Nasional", "Sekolah libur pada tanggal...", "7 hari lalu"),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Jadwal Hari Ini", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JadwalPage()),
                );
              },
              child: Text("Kalender", style: TextStyle(color: Colors.grey[600])),
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
              BoxShadow(color: Colors.black12, offset: Offset(0, 3), blurRadius: 6),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _scheduleItem("Matematika", "08:00 - 08:45"),
              _scheduleItem("Bahasa Indonesia", "08:45 - 09:30"),
              _scheduleItem("Olahraga", "10:00 - 10:45"),
              _scheduleItem("Agama", "10:45 - 11:30"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _attendanceItem(IconData icon, String title, String count, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: color, fontSize: 13)),
        Text(count, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _announcementCard(String title, String subtitle, String time) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Membuka detail: $title')),
        );
      },
      child: Container(
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _scheduleItem(String subject, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(subject, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          Text(time, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}