import 'package:flutter/material.dart';
import 'dashboard_orangtua.dart';
import 'perizinan.dart';
import 'jadwal.dart';
import 'pembayaran.dart';
import 'profil.dart';
import 'agenda.dart';
import 'package:frontend/auth/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/widgets/notifikasi_widgets.dart';
import 'package:frontend/env/api_base_url.dart';

class PengumumanOrtu {
  final int pengumumanId;
  final String judul;
  final String isi;
  final String tipe;
  final DateTime tanggal;
  final Map<String, dynamic>? guru;

  PengumumanOrtu({
    required this.pengumumanId,
    required this.judul,
    required this.isi,
    required this.tipe,
    required this.tanggal,
    this.guru,
  });

  factory PengumumanOrtu.fromJson(Map<String, dynamic> json) {
    return PengumumanOrtu(
      pengumumanId: json['Pengumuman_Id'] ?? 0,
      judul: json['Judul'] ?? '',
      isi: json['Isi'] ?? '',
      tipe: json['Tipe'] ?? 'umum',
      tanggal: json['Tanggal'] != null
          ? DateTime.parse(json['Tanggal'])
          : DateTime.now(),
      guru: json['guru'],
    );
  }

  String get kategoriDisplay {
    switch (tipe) {
      case 'personal':
        return 'Personal';
      case 'perkelas':
        return 'Kelas';
      default:
        return 'Umum';
    }
  }
}

class PengumumanOrtuApiService {
  static String get baseUrl => '${ApiConfig.baseUrl}/api';

  static Future<Map<String, String>> _getHeaders() async {
    final token = globalAuthToken;

    return {
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<PengumumanOrtu>> getPengumumanOrtu([
    String kategori = 'semua',
  ]) async {
    try {
      final headers = await _getHeaders();

      final uri = (kategori == 'semua')
          ? Uri.parse('$baseUrl/orangtua/pengumuman')
          : Uri.parse('$baseUrl/orangtua/pengumuman/$kategori');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((e) => PengumumanOrtu.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

class PengumumanPage extends StatefulWidget {
  const PengumumanPage({super.key});

  @override
  State<PengumumanPage> createState() => _PengumumanPageState();
}

class _PengumumanPageState extends State<PengumumanPage> {
  int _selectedIndex = 2;
  String _selectedKategori = 'Semua';

  final List<String> _kategoriList = ['Semua', 'Umum', 'Kelas', 'Personal'];

  final Map<String, String> kategoriApiMap = {
    'Semua': 'semua',
    'Umum': 'umum',
    'Kelas': 'perkelas',
    'Personal': 'personal',
  };

  List<PengumumanOrtu> _apiPengumumanList = [];

  @override
  void initState() {
    super.initState();
    _loadPengumumanFromApi(kategoriApiMap[_selectedKategori]!);
  }

  void _loadPengumumanFromApi([String kategori = 'semua']) async {
    final pengumuman = await PengumumanOrtuApiService.getPengumumanOrtu(
      kategori,
    );
    setState(() {
      _apiPengumumanList = pengumuman;
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget? targetPage;
    switch (index) {
      case 0:
        targetPage = DashboardPage();
        break;
      case 1:
        targetPage = JadwalPage();
        break;
      case 2:
        break;
      case 3:
        targetPage = RincianPembayaranPage();
        break;
      case 4:
        targetPage = ProfilPage();
        break;
    }
    if (targetPage != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => targetPage!),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF465940);
    const Color backgroundColor = Color(0xFFFDFBF0);

    final filteredList = _apiPengumumanList;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: greenColor),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.school, color: greenColor),
            SizedBox(width: 6),
            Text(
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
          child: Container(color: Colors.black12, height: 1.0),
        ),
      ),

      drawer: Drawer(
        backgroundColor: backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: greenColor),
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
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            }, color: Colors.red),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.campaign, color: greenColor),
                  const SizedBox(width: 8),
                  const Text(
                    "Pengumuman :",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: greenColor,
                    ),
                  ),
                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: greenColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedKategori,
                        dropdownColor: greenColor,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                        items: _kategoriList.map((String kategori) {
                          return DropdownMenuItem<String>(
                            value: kategori,
                            child: Text(kategori),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedKategori = newValue!;
                          });

                          final apiKategori = kategoriApiMap[newValue]!;
                          _loadPengumumanFromApi(apiKategori);
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Column(
                  key: ValueKey<String>(_selectedKategori),
                  children: filteredList.map((pengumuman) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: greenColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pengumuman.judul,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDFBF0),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  pengumuman.kategoriDisplay,
                                  style: TextStyle(
                                    color: greenColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pengumuman.isi,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(pengumuman.tanggal),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.person,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                pengumuman.guru?['Nama'] ?? 'Guru',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              if (filteredList.isEmpty) ...[
                const SizedBox(height: 50),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada pengumuman',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pengumuman ${_selectedKategori.toLowerCase()} belum tersedia',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 80),
            ],
          ),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profil'),
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
}