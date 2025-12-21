import 'package:flutter/material.dart';
import 'package:frontend/orangtua/dashboard_orangtua.dart';
import 'package:frontend/orangtua/perizinan.dart';
import 'package:frontend/orangtua/pengumuman.dart';
import 'package:frontend/orangtua/pembayaran.dart';
import 'package:frontend/orangtua/profil.dart';
import 'package:frontend/orangtua/agenda.dart';
import 'package:frontend/auth/login.dart';
import 'package:frontend/widgets/notifikasi_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/env/api_base_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  final Color greenColor = const Color(0xFF465940);
  final Color backgroundColor = const Color(0xFFFDFBF0);
  int _selectedIndex = 1;
  
  // State untuk data API
  String? authToken;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  
  // Data dari API
  Map<String, dynamic>? siswaData;
  Map<String, dynamic> jadwalData = {};
  
  // Hari dalam urutan
  final List<String> hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

  @override
  void initState() {
    super.initState();
    _loadTokenAndData();
  }

  // ===================== LOAD TOKEN =====================
  Future<void> _loadTokenAndData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');
      setState(() {
        authToken = token;
      });
      
      if (authToken != null) {
        await _loadJadwalData();
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Token tidak ditemukan. Silakan login ulang.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  // ===================== LOAD JADWAL DATA =====================
  Future<void> _loadJadwalData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/orangtua/jadwal-pelajaran'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        if (json['success'] == true) {
          setState(() {
            siswaData = json['data']['siswa'] != null 
                ? Map<String, dynamic>.from(json['data']['siswa'])
                : null;
            jadwalData = json['data']['jadwal'] != null
                ? Map<String, dynamic>.from(json['data']['jadwal'])
                : {};
            isLoading = false;
          });
        } else {
          setState(() {
            hasError = true;
            errorMessage = json['message'] ?? 'Gagal memuat data';
            isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        // Unauthorized - token expired
        setState(() {
          hasError = true;
          errorMessage = 'Sesi telah berakhir. Silakan login ulang.';
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Error ${response.statusCode}: Gagal memuat data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Koneksi bermasalah: $e';
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardPage()),
        );
        break;
      case 1:
        break; // tetap di Jadwal
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PengumumanPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RincianPembayaranPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfilPage()),
        );
        break;
    }
  }

  // ===================== BUILD JADWAL PER HARI =====================
  Widget _buildHariCard(String hari) {
    List<dynamic> jadwalHari = [];
    
    if (jadwalData.containsKey(hari)) {
      jadwalHari = jadwalData[hari] is List 
          ? List<dynamic>.from(jadwalData[hari])
          : [];
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER HARI
          Text(
            "$hari:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: greenColor,
            ),
          ),
          const SizedBox(height: 8),
          
          // JIKA TIDAK ADA JADWAL
          if (jadwalHari.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: greenColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: greenColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Tidak ada jadwal pelajaran",
                      style: TextStyle(
                        color: greenColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            // JADWAL PELAJARAN
            Container(
              decoration: BoxDecoration(
                color: greenColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                children: jadwalHari.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = Map<String, dynamic>.from(entry.value as Map);
                  
                  return Container(
                    margin: EdgeInsets.only(bottom: index == jadwalHari.length - 1 ? 0 : 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 90,
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(
                            item['jam']?.toString() ?? '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // MATA PELAJARAN
                        Expanded(
                          child: Text(
                            item['mata_pelajaran']?.toString() ?? '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ===================== HEADER SISWA INFO =====================
  Widget _buildSiswaInfo() {
    if (siswaData == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: greenColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Data siswa/anak belum tersedia",
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: greenColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // ICON SISWA
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.school, color: greenColor, size: 30),
          ),
          
          const SizedBox(width: 16),
          
          // INFO SISWA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  siswaData!['nama']?.toString() ?? 'Nama Siswa',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Kelas: ${siswaData!['kelas']?.toString() ?? '-'}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Tahun Ajar: ${siswaData!['tahun_ajar']?.toString() ?? '-'}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // REFRESH BUTTON
          IconButton(
            onPressed: _loadJadwalData,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Refresh",
          ),
        ],
      ),
    );
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
          NotifikasiBadge(
            iconColor: greenColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotifikasiPage()),
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
            _drawerItem(Icons.person, "Profil", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ProfilPage()),
              );
            }),
            const Divider(),
            _drawerItem(Icons.logout, "Keluar", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            }),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // JUDUL
            const Text(
              "Jadwal Pelajaran",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF465940),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Jadwal pelajaran anak Anda",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 20),
            
            // LOADING STATE
            if (isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: greenColor),
                      const SizedBox(height: 16),
                      const Text(
                        "Memuat data jadwal...",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              )
            
            // ERROR STATE
            else if (hasError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadJadwalData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenColor,
                        ),
                        child: const Text("Coba Lagi"),
                      ),
                    ],
                  ),
                ),
              )
            
            // SUCCESS STATE
            else
              Column(
                children: [
                  // INFO SISWA
                  _buildSiswaInfo(),
                  const SizedBox(height: 24),
                  
                  // JADWAL PER HARI
                  ...hariList.map((hari) => _buildHariCard(hari)).toList(),
                ],
              ),
            
            const SizedBox(height: 80),
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

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: greenColor),
      title: Text(title, style: const TextStyle(color: Colors.black87)),
      onTap: onTap,
    );
  }
}