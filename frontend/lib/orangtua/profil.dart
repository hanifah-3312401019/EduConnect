import 'package:flutter/material.dart';
import 'dashboard_orangtua.dart';
import 'jadwal.dart';
import 'pengumuman.dart';
import 'pembayaran.dart';
import 'edit_profil_orangtua.dart';
import 'edit_profil_anak.dart';
import 'agenda.dart';
import 'package:frontend/auth/login.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF465940);
    const Color backgroundColor = Color(0xFFFDFBF0);
    int _selectedIndex = 4;

    void _onItemTapped(int index) {
      Widget? targetPage;
      switch (index) {
        case 0:
          targetPage = DashboardPage();
          break;
        case 1:
          targetPage = JadwalPage();
          break;
        case 2:
          targetPage = PengumumanPage();
          break;
        case 3:
          targetPage = RincianPembayaranPage();
          break;
        case 4:
          break;
      }
      if (targetPage != null && targetPage.runtimeType != ProfilPage) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => targetPage!),
        );
      }
    }

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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PengumumanPage()),
              );
            }),
            _drawerItem(Icons.payment, "Pembayaran", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => RincianPembayaranPage()),
              );
            }),
            _drawerItem(Icons.person, "Profil", () {}),
            const Divider(),
            _drawerItem(Icons.logout, "Keluar", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            }, color: Colors.red),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header hijau profil
            Container(
              width: double.infinity,
              color: greenColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: greenColor, size: 40),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nama : [Nama Orang Tua]",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Status : Orang tua",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDataCard(
                      context: context,
                      fields: const [
                        "Nama Orang Tua",
                        "No Telepon",
                        "Email",
                        "Alamat",
                      ],
                      buttonText: "Edit Data Orang Tua",
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditOrangTuaPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDataCard(
                      context: context,
                      fields: const [
                        "Nama Anak",
                        "Ekstrakulikuler",
                        "Tanggal Lahir",
                        "Jenis Kelamin",
                        "Agama",
                        "Alamat",
                      ],
                      buttonText: "Edit Data Anak",
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditAnakPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: greenColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Halaman Utama',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
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
      leading: Icon(icon, color: color ?? const Color(0xFF465940)),
      title: Text(title, style: TextStyle(color: color ?? Colors.black87)),
      onTap: onTap,
    );
  }

  Widget _buildDataCard({
    required BuildContext context,
    required List<String> fields,
    required String buttonText,
    required VoidCallback onEdit,
  }) {
    const Color greenColor = Color(0xFF465940);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: greenColor, width: 1.8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FixedColumnWidth(8),
              2: FlexColumnWidth(),
            },
            children: fields
                .map(
                  (field) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          field,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(":", style: TextStyle(fontSize: 15)),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "",
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: onEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 10,
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
