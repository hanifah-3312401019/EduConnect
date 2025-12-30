import 'package:flutter/material.dart';
import 'package:frontend/widgets/sidebarOrangtua.dart';
import 'jadwal.dart';
import 'pengumuman.dart';
import 'pembayaran.dart';
import 'profil.dart';
import 'package:frontend/widgets/notifikasi_widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/env/api_base_url.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/auth/login.dart';
import 'package:frontend/widgets/pdf_viewer_page.dart';

class DashboardPengumuman {
  final String judul;
  final String isi;
  final DateTime tanggal;
  final String tipe;
  final Map<String, dynamic>? guru;

  DashboardPengumuman({
    required this.judul,
    required this.isi,
    required this.tanggal,
    required this.tipe,
    this.guru,
  });

  factory DashboardPengumuman.fromJson(Map<String, dynamic> json) {
    return DashboardPengumuman(
      judul: json['Judul'] ?? '',
      isi: json['Isi'] ?? '',
      tanggal: json['Tanggal'] != null
          ? DateTime.parse(json['Tanggal'])
          : DateTime.now(),
      tipe: json['Tipe'] ?? 'umum',
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

class SiswaData {
  final String? nama;
  final String? kelas;
  final String? tahunAjar;

  SiswaData({
    this.nama,
    this.kelas,
    this.tahunAjar,
  });

  factory SiswaData.fromJson(Map<String, dynamic> json) {
    return SiswaData(
      nama: json['nama']?.toString(),
      kelas: json['kelas']?.toString(),
      tahunAjar: json['tahun_ajar']?.toString(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Color greenColor = const Color(0xFF465940);
  final Color backgroundColor = const Color(0xFFFDFBF0);
  int _selectedIndex = 0;
  
  List<DashboardPengumuman> _pengumumanList = [];
  SiswaData? _siswaData;
  Map<String, dynamic> _jadwalData = {};
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String? _authToken;
  
  final List<String> hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

  @override
  void initState() {
    super.initState();
    _loadTokenAndData();
  }

  Future<void> _loadTokenAndData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');
      
      if (token == null || token.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Token tidak ditemukan. Silakan login ulang.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _authToken = token;
      });

      await Future.wait([
        _loadPengumumanData(token),
        _loadJadwalData(token),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPengumumanData(String token) async {
    try {
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/orangtua/pengumuman/semua'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> pengumumanList = data['data'];
          
          List<DashboardPengumuman> tempList = [];
          for (var item in pengumumanList) {
            tempList.add(DashboardPengumuman.fromJson(item));
          }
          
          tempList.sort((a, b) => b.tanggal.compareTo(a.tanggal));
          
          setState(() {
            _pengumumanList = tempList.take(2).toList();
          });
        } else {
          setState(() {
            _pengumumanList = [];
          });
        }
      } else if (response.statusCode == 401) {
        _handleTokenExpired();
      }
    } catch (e) {
      setState(() {
        _pengumumanList = [];
      });
    }
  }

  Future<void> _loadJadwalData(String token) async {
    try {
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/orangtua/jadwal-pelajaran'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          setState(() {
            _siswaData = SiswaData.fromJson(data['data']['siswa'] ?? {});
            _jadwalData = data['data']['jadwal'] ?? {};
          });
        } else {
          setState(() {
            _hasError = true;
            _errorMessage = data['message'] ?? 'Gagal memuat data jadwal';
          });
        }
      } else if (response.statusCode == 401) {
        _handleTokenExpired();
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Error ${response.statusCode}: Gagal memuat data';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Koneksi bermasalah: $e';
      });
    }
  }

  void _handleTokenExpired() {
    setState(() {
      _hasError = true;
      _errorMessage = 'Sesi telah berakhir. Silakan login ulang.';
    });
    
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      }
    });
  }

    Future<void> _downloadKalenderAkademik() async {
    final uri = Uri.parse(
      'https://drive.google.com/uc?export=download&id=1nEQ5SJredk9Y04cazgPj-hhOIVXM0rA7',
    );

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      _showDownloadDialog();
    }
  }


  void _showDownloadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf, color: Color(0xFF465940)),
            SizedBox(width: 10),
            Text('Kalender Akademik'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.download,
              size: 60,
              color: Color(0xFF465940),
            ),
            SizedBox(height: 15),
            Text(
              'Download Kalender Akademik',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Kalender akademik dapat diunduh melalui link berikut:',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15),
            Text(
              'https://drive.google.com/uc?export=download&id=1nEQ5SJredk9Y04cazgPj-hhOIVXM0rA7',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('TUTUP'),
          ),
        ],
      ),
    );
  }

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

  Widget _buildPerizinanSection() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: greenColor.withOpacity(0.3)),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          offset: Offset(0, 2),
          blurRadius: 4,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.health_and_safety, color: greenColor, size: 20),
            const SizedBox(width: 8),
            const Text(
              "Perizinan Anak",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _perizinanCard(
                Icons.favorite,
                "Sakit",
                "2 hari",
                Colors.red.shade100,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _perizinanCard(
                Icons.timer,
                "Izin",
                "3 hari",
                Colors.blue.shade100,
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _perizinanCard(IconData icon, String title, String count, Color bgColor, Color iconColor) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: iconColor.withOpacity(0.2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Text(
          count,
          style: TextStyle(
            color: iconColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
            const Text(
              "Pengumuman Terbaru",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PengumumanPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Lihat Semua",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (_pengumumanList.isEmpty)
          _buildEmptyAnnouncement()
        else
          ..._pengumumanList.map((pengumuman) => 
            _announcementCardFromApi(pengumuman)
          ).toList(),
      ],
    );
  }

  Widget _buildEmptyAnnouncement() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Belum ada pengumuman",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _announcementCardFromApi(DashboardPengumuman pengumuman) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.campaign,
            color: greenColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pengumuman.judul,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  pengumuman.isi.length > 60 
                    ? '${pengumuman.isi.substring(0, 60)}...' 
                    : pengumuman.isi,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(pengumuman.tanggal),
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getCategoryColor(pengumuman.tipe),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              pengumuman.kategoriDisplay,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String tipe) {
    switch (tipe) {
      case 'personal':
        return Colors.blue;
      case 'perkelas':
        return Colors.green;
      default:
        return Colors.redAccent;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildScheduleSectionToday() {
    final hariSekarang = _getHariSekarang();
    final jadwalHariIni = _jadwalData[hariSekarang] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Jadwal Hari Ini ($hariSekarang)",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => JadwalPage()),
                );
              },
              child: Text(
                "Lihat Semua",
                style: TextStyle(color: greenColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (jadwalHariIni.isEmpty)
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
                    "Tidak ada jadwal pelajaran hari ini",
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
              children: jadwalHariIni.map<Widget>((item) {
                final mapItem = Map<String, dynamic>.from(item as Map);
                return _buildScheduleItem(
                  mapItem['mata_pelajaran']?.toString() ?? '-',
                  mapItem['jam']?.toString() ?? '-',
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  String _getHariSekarang() {
    final now = DateTime.now();
    final dayIndex = now.weekday;
    
    switch (dayIndex) {
      case 1: return 'Senin';
      case 2: return 'Selasa';
      case 3: return 'Rabu';
      case 4: return 'Kamis';
      case 5: return 'Jumat';
      case 6: return 'Sabtu';
      case 7: return 'Minggu';
      default: return 'Senin';
    }
  }

  Widget _buildScheduleItem(String subject, String time) {
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
          Text(
            time,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: greenColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.school, color: greenColor, size: 30),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _siswaData?.nama ?? 'Nama Siswa',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Kelas: ${_siswaData?.kelas ?? '-'}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Tahun Ajar: ${_siswaData?.tahunAjar ?? '-'}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          IconButton(
            onPressed: _loadTokenAndData,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Refresh",
          ),
        ],
      ),
    );
  }

  Widget _buildKalenderAkademikSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Kalender Akademik",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            GestureDetector(
              onTap: _downloadKalenderAkademik,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: greenColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.download, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      "Download",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _downloadKalenderAkademik,
          child: Container(
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
            child: const Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kalender Akademik 2024/2025",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Download PDF kalender akademik lengkap",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginRequiredSection() {
    return Center(
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
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text("Login Sekarang"),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadTokenAndData,
              child: Text(
                "Coba Lagi",
                style: TextStyle(color: greenColor),
              ),
            ),
          ],
        ),
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
              if (_authToken != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotifikasiPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.black.withOpacity(0.2), height: 1.0),
        ),
      ),
      drawer: const sidebarOrangtua(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: greenColor),
                      const SizedBox(height: 16),
                      const Text(
                        "Memuat data dashboard...",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              )
            else if (_hasError)
              _buildLoginRequiredSection()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_siswaData != null) ...[
                    _buildSiswaInfoSection(),
                    const SizedBox(height: 20),
                  ],
                  
                  _buildPerizinanSection(),
                  const SizedBox(height: 24),
                  
                  _buildAnnouncementSection(),
                  const SizedBox(height: 24),
                  
                  _buildScheduleSectionToday(),
                  const SizedBox(height: 20),
                  
                  _buildKalenderAkademikSection(),
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
}