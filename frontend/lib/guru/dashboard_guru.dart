import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../widgets/sidebar.dart';
import '../widgets/navigation_bar_guru.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardGuru extends StatelessWidget {
  const DashboardGuru({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;

        if (isMobile) {
          return Scaffold(
            backgroundColor: const Color(0xFFFDFBF0),
            appBar: AppBar(
              title: const Text(
                'EduConnect',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color(0xFF465940),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
            ),
            drawer: const Sidebar(),
            body: const SafeArea(child: DashboardContent()),
            bottomNavigationBar: const NavigationBarMobile(),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFDFBF0),
          appBar: AppBar(
            title: const Text(
              'EduConnect',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFF465940),
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ),
          drawer: const Sidebar(),
          body: const SafeArea(child: DashboardContent()),
        );
      },
    );
  }
}

class NavigationBarMobile extends StatefulWidget {
  const NavigationBarMobile({super.key});

  @override
  State<NavigationBarMobile> createState() => _NavigationBarMobileState();
}

class _NavigationBarMobileState extends State<NavigationBarMobile> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              // Tetap di dashboard
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/guru/absensi');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/guru/agenda');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/guru/pengumuman');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF465940),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Utama'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Absensi'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Pengumuman',
          ),
        ],
      ),
    );
  }
}

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  String _guruNama = '';
  String _kelasNama = '';
  List<dynamic> _pengumumanList = [];
  bool _isLoading = true;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _onRefresh() async {
    await _loadData();
    _refreshController.refreshCompleted();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final guruId = prefs.getInt('Guru_Id');
    
    setState(() {
      _guruNama = prefs.getString('Guru_Nama') ?? 'Guru';
    });

    // 1. Load kelas guru dari endpoint yang sudah ada
    try {
      final kelasResponse = await http.get(
        Uri.parse('http://localhost:8000/api/guru/kelas-saya'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          if (guruId != null) 'Guru_Id': guruId.toString(),
        },
      );

      print('Kelas Response Status: ${kelasResponse.statusCode}');
      print('Kelas Response Body: ${kelasResponse.body}');

      if (kelasResponse.statusCode == 200) {
        final kelasData = json.decode(kelasResponse.body);
        if (kelasData['success'] == true && kelasData['data'] != null) {
          if (kelasData['data'] is List && kelasData['data'].isNotEmpty) {
            setState(() {
              // Ambil nama kelas pertama jika ada beberapa
              _kelasNama = kelasData['data'][0]['Nama_Kelas'] ?? 'Belum ada kelas';
            });
            print('Kelas ditemukan: $_kelasNama');
          } else {
            setState(() {
              _kelasNama = 'Belum ada kelas yang ditugaskan';
            });
            print('Data kelas kosong');
          }
        } else {
          setState(() {
            _kelasNama = 'Gagal memuat data kelas';
          });
          print('Response tidak success: ${kelasData['message']}');
        }
      } else if (kelasResponse.statusCode == 404) {
        setState(() {
          _kelasNama = 'Anda belum memiliki kelas';
        });
        print('Guru tidak memiliki kelas (404)');
      } else {
        setState(() {
          _kelasNama = 'Error: ${kelasResponse.statusCode}';
        });
        print('Error status: ${kelasResponse.statusCode}');
      }
    } catch (e) {
      print('Error loading kelas: $e');
      setState(() {
        _kelasNama = 'Error memuat kelas';
      });
    }

    // 2. Load pengumuman terbaru
    try {
      final pengumumanResponse = await http.get(
        Uri.parse('http://localhost:8000/api/guru/pengumuman'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          if (guruId != null) 'Guru_Id': guruId.toString(),
        },
      );

      print('Pengumuman Response Status: ${pengumumanResponse.statusCode}');
      
      if (pengumumanResponse.statusCode == 200) {
        final pengumumanData = json.decode(pengumumanResponse.body);
        if (pengumumanData['success'] == true && pengumumanData['data'] != null) {
          // Ambil hanya 2 pengumuman terbaru untuk dashboard
          final allPengumuman = List.from(pengumumanData['data']);
          
          // Urutkan berdasarkan tanggal terbaru
          allPengumuman.sort((a, b) {
            try {
              final dateA = DateTime.parse(a['Tanggal'] ?? a['created_at'] ?? DateTime.now().toIso8601String());
              final dateB = DateTime.parse(b['Tanggal'] ?? b['created_at'] ?? DateTime.now().toIso8601String());
              return dateB.compareTo(dateA);
            } catch (e) {
              return 0;
            }
          });
          
          setState(() {
            _pengumumanList = allPengumuman.take(2).toList();
          });
          print('Pengumuman ditemukan: ${_pengumumanList.length} item');
        } else {
          print('Response pengumuman tidak success: ${pengumumanData['message']}');
        }
      } else {
        print('Error status pengumuman: ${pengumumanResponse.statusCode}');
      }
    } catch (e) {
      print('Error loading pengumuman: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getTimeAgo(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays > 0) {
        return '${difference.inDays} hari yang lalu';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit yang lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;

        if (_isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: const Color(0xFF465940),
            ),
          );
        }

        return SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          enablePullDown: true,
          header: const ClassicHeader(
            completeText: 'Data diperbarui',
            refreshingText: 'Memuat...',
            releaseText: 'Lepas untuk refresh',
            idleText: 'Tarik ke bawah untuk refresh',
          ),
          child: isMobile ? _buildMobileLayout() : _buildWebLayout(),
        );
      },
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(isMobile: true),
          const SizedBox(height: 20),
          _buildDateCard(isMobile: true),
          const SizedBox(height: 20),
          _buildAttendanceStats(isMobile: true),
          const SizedBox(height: 20),
          _buildAnnouncements(isMobile: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWebLayout() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(isMobile: false),
          const SizedBox(height: 24),
          _buildDateCard(isMobile: false),
          const SizedBox(height: 24),
          _buildAttendanceStats(isMobile: false),
          const SizedBox(height: 24),
          _buildAnnouncements(isMobile: false),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader({required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat Datang, $_guruNama',
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF465940),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _kelasNama.isNotEmpty 
                ? 'Pantau Perkembangan - $_kelasNama'
                : 'Belum ada kelas yang ditugaskan',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard({required bool isMobile}) {
    final now = DateTime.now();
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 
                    'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    
    final dayName = days[now.weekday % 7];
    final formattedDate = '${now.day} ${months[now.month - 1]} ${now.year}';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            size: isMobile ? 20 : 24,
            color: const Color(0xFF465940),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Text(
              '$dayName, $formattedDate',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF465940),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStats({required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Kehadiran',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF465940),
            ),
          ),
          const SizedBox(height: 16),

          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatBox(
                      '20',
                      'Hadir',
                      Colors.green,
                      isMobile: isMobile,
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  Expanded(
                    child: _buildStatBox(
                      '1',
                      'Sakit',
                      Colors.orange,
                      isMobile: isMobile,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatBox(
                      '0',
                      'Izin',
                      Colors.blue,
                      isMobile: isMobile,
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  Expanded(
                    child: _buildStatBox(
                      '0',
                      'Alfa',
                      Colors.red,
                      isMobile: isMobile,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(
    String value,
    String label,
    Color color, {
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncements({required bool isMobile}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pengumuman Terbaru',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF465940),
                ),
              ),
              if (_pengumumanList.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/guru/pengumuman');
                  },
                  child: Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: const Color(0xFF465940),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),

          if (_pengumumanList.isEmpty)
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.announcement_outlined,
                      size: isMobile ? 40 : 50,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada pengumuman',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Buat pengumuman pertama Anda',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: _pengumumanList.map((pengumuman) => 
                _buildPengumumanItem(pengumuman, isMobile: isMobile)
              ).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPengumumanItem(Map<String, dynamic> pengumuman, {required bool isMobile}) {
    final judul = pengumuman['Judul'] ?? 'Tanpa Judul';
    final isi = pengumuman['Isi'] ?? '';
    final tipe = pengumuman['Tipe'] ?? 'umum';
    final tanggal = pengumuman['Tanggal'] ?? pengumuman['created_at'] ?? DateTime.now().toIso8601String();
    final waktu = _getTimeAgo(tanggal);

    Color tipeColor;
    String tipeText;
    
    if (tipe.toLowerCase() == 'personal') {
      tipeColor = Colors.purple;
      tipeText = 'Personal';
    } else if (tipe.toLowerCase() == 'perkelas') {
      tipeColor = Colors.blue;
      tipeText = 'Perkelas';
    } else {
      tipeColor = Colors.green;
      tipeText = 'Umum';
    }

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  judul,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF465940),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tipeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tipeText,
                  style: TextStyle(
                    color: tipeColor,
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            isi.length > 100 ? '${isi.substring(0, 100)}...' : isi,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: isMobile ? 12 : 14,
                color: tipeColor,
              ),
              SizedBox(width: 4),
              Text(
                waktu,
                style: TextStyle(
                  fontSize: isMobile ? 11 : 13,
                  color: tipeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(tanggal),
                style: TextStyle(
                  fontSize: isMobile ? 11 : 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}