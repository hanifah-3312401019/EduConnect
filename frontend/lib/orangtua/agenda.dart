import 'package:flutter/material.dart';
import 'dashboard_orangtua.dart';
import 'jadwal.dart';
import 'pengumuman.dart';
import 'pembayaran.dart';
import 'profil.dart';
import 'package:frontend/auth/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/widgets/notifikasi_widgets.dart';

// import sidebar reusable
import 'package:frontend/widgets/sidebarOrangtua.dart';

class AgendaOrtuModel {
  final int agendaId;
  final String judul;
  final String deskripsi;
  final String tipe;
  final DateTime tanggal;
  final String waktuMulai;
  final String waktuSelesai;
  final Map<String, dynamic>? guru;
  final Map<String, dynamic>? kelas;
  final Map<String, dynamic>? ekstrakulikuler;

  AgendaOrtuModel({
    required this.agendaId,
    required this.judul,
    required this.deskripsi,
    required this.tipe,
    required this.tanggal,
    required this.waktuMulai,
    required this.waktuSelesai,
    this.guru,
    this.kelas,
    this.ekstrakulikuler,
  });

  factory AgendaOrtuModel.fromJson(Map<String, dynamic> json) {
    return AgendaOrtuModel(
      agendaId: json['Agenda_Id'] ?? 0,
      judul: json['Judul'] ?? '',
      deskripsi: json['Deskripsi'] ?? '',
      tipe: json['Tipe'] ?? 'sekolah',
      tanggal: DateTime.parse(json['Tanggal'] ?? DateTime.now().toIso8601String()),
      waktuMulai: json['Waktu_Mulai'] ?? '08:00',
      waktuSelesai: json['Waktu_Selesai'] ?? '10:00',
      guru: json['guru'],
      kelas: json['kelas'],
      ekstrakulikuler: json['ekstrakulikuler'],
    );
  }

  String get kategoriDisplay {
    switch (tipe.toLowerCase()) {
      case 'sekolah':
        return 'Sekolah';
      case 'perkelas':
        return 'Kelas';
      case 'ekskul':
        return 'Ekstrakurikuler';
      default:
        return tipe;
    }
  }

  String get waktuDisplay {
    return '${waktuMulai.substring(0, 5)} - ${waktuSelesai.substring(0, 5)}';
  }
}

// API SERVICE AGENDA ORANGTUA
class AgendaOrtuApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  static Future<Map<String, String>> _getHeaders() async {
    final token = globalAuthToken;

    print('🔎 TOKEN TERAMBIL DARI GLOBAL: $token');

    return {
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<AgendaOrtuModel>> getAgendaOrtu([
    String kategori = 'semua',
  ]) async {
    try {
      final headers = await _getHeaders();

      final uri = (kategori == 'semua')
          ? Uri.parse('$baseUrl/orangtua/agenda')
          : Uri.parse('$baseUrl/orangtua/agenda/$kategori');

      final response = await http.get(uri, headers: headers);

      print("📥 AGENDA STATUS: ${response.statusCode}");
      print("📥 AGENDA BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((e) => AgendaOrtuModel.fromJson(e))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('❌ Error API Agenda: $e');
      return [];
    }
  }
}

// PAGE AGENDA ORANGTUA
class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  int _selectedIndex = 1;
  String _selectedKategori = 'Semua';

  final List<String> _kategoriList = ['Semua', 'Sekolah', 'Kelas', 'Ekstrakurikuler'];

  // ⭐ FIX MAPPING KATEGORI API
  final Map<String, String> kategoriApiMap = {
    'Semua': 'semua',
    'Sekolah': 'sekolah',
    'Kelas': 'perkelas',
    'Ekstrakurikuler': 'ekskul',
  };

  List<AgendaOrtuModel> _apiAgendaList = [];

  @override
  void initState() {
    super.initState();
    _loadAgendaFromApi(kategoriApiMap[_selectedKategori]!);
  }

  void _loadAgendaFromApi([String kategori = 'semua']) async {
    final agenda = await AgendaOrtuApiService.getAgendaOrtu(kategori);
    setState(() {
      _apiAgendaList = agenda;
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
        break;
      case 2:
        targetPage = JadwalPage();
        break;
      case 3:
        targetPage = const PengumumanPage();
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
    final List<String> monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    
    return '${date.day.toString().padLeft(2, '0')} ${monthNames[date.month]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF465940);
    const Color backgroundColor = Color(0xFFFDFBF0);

    final filteredList = _apiAgendaList;

    return Scaffold(
      backgroundColor: backgroundColor,

      // 🔥 sidebar pakai file reusable
      drawer: const sidebarOrangtua(),

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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.event_note, color: greenColor),
                  const SizedBox(width: 8),
                  const Text(
                    "Agenda",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: greenColor,
                    ),
                  ),
                  const Spacer(),
                  // DROPDOWN (FIX API)
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
                          _loadAgendaFromApi(apiKategori);
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
                  children: filteredList.map((agenda) {
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
                                  agenda.judul,
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
                                  agenda.kategoriDisplay,
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
                            agenda.deskripsi,
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
                                _formatDate(agenda.tanggal),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                agenda.waktuDisplay,
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
                                agenda.guru?['Nama'] ?? 'Guru',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          // Tampilkan info tambahan berdasarkan tipe
                          // DIHAPUS: Bagian yang menampilkan ikon kelas dan ekstrakulikuler
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
                        Icons.event_note_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada agenda',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Agenda ${_selectedKategori.toLowerCase()} belum tersedia',
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

      // Bottom Navigation
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
            icon: Icon(Icons.event),
            label: 'Agenda',
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
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
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