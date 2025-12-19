import 'package:flutter/material.dart';
import 'package:frontend/widgets/sidebarAdmin.dart';
import 'package:frontend/admin/data_siswa.dart';
import 'package:frontend/admin/data_guru.dart';
import 'package:frontend/admin/data_orangTua.dart';
import 'package:frontend/admin/data_kelas.dart';
import 'package:frontend/admin/jadwal_pelajaran.dart';
import 'package:frontend/admin/informasi_pembayaran.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/env/api_base_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  // ===================== STATE VARIABLES =====================
  Map<String, dynamic>? stats;
  bool isLoading = true;
  bool hasError = false;
  List<Map<String, dynamic>> recentActivities = [];
  List<Map<String, dynamic>> chartData = [];
  String errorMessage = '';
  String? authToken;

  // ===================== INIT & DISPOSE =====================
  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  // ===================== INISIALISASI DASHBOARD =====================
  Future<void> _initializeDashboard() async {
    await _loadToken();
    await _loadDashboard();
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (!mounted) return;

      setState(() {
        authToken = token;
      });

      print('TOKEN LOADED: $token');
    } catch (e) {
      print('Error loading token: $e');
    }
  }

  // ===================== LOAD DASHBOARD DATA =====================
  Future<void> _loadDashboard() async {
    if (authToken == null || authToken!.isEmpty) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Token tidak ditemukan. Silakan login kembali.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      final statsRes = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/dashboard/stats'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (statsRes.statusCode == 200) {
        final json = jsonDecode(statsRes.body);

        if (json['success'] == true) {
          setState(() {
            stats = json['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            hasError = true;
            errorMessage = json['message'] ?? 'Gagal memuat data dashboard';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'HTTP Error ${statsRes.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Koneksi bermasalah: $e';
      });
    }
  }

  // ===================== NAVIGASI =====================
  void handleMenu(String menu) {
    Widget? page;

    switch (menu) {
      case "Dashboard":
        page = const DashboardAdminPage();
        break;
      case "Data Guru":
        page = const DataGuruPage();
        break;
      case "Data Siswa":
        page = const DataSiswaPage();
        break;
      case "Data Orang Tua":
        page = const DataOrangTuaPage();
        break;
      case "Data Kelas":
        page = const DataKelasPage();
        break;
      case "Jadwal Pelajaran":
        page = const JadwalPelajaranPage();
        break;
      case "Informasi Pembayaran":
        page = const DataPembayaranPage();
        break;
    }

    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page!),
      );
    }
  }

  // ===================== BUILD METHOD =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF0),
      body: Row(
        children: [
          SidebarAdmin(onMenuSelected: handleMenu),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 28,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===================== HEADER DASHBOARD =====================
                          _buildDashboardHeader(),
                          const SizedBox(height: 35),

                          // ===================== LOADING/ERROR STATE =====================
                          if (isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 50),
                                child: CircularProgressIndicator(
                                  color: Color(0xFF465940),
                                ),
                              ),
                            )
                          else if (hasError)
                            _buildErrorState()
                          else
                            _buildDashboardContent(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== DASHBOARD CONTENT =====================
  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===================== STATISTICS CARDS =====================
        _buildStatsGrid(),
        const SizedBox(height: 35),

        // ===================== CHARTS SECTION =====================
        if (chartData.isNotEmpty) ...[
          _buildChartsSection(),
          const SizedBox(height: 35),
        ],

        // ===================== RECENT ACTIVITIES =====================
        if (recentActivities.isNotEmpty) ...[
          _buildRecentActivities(),
          const SizedBox(height: 35),
        ],

        // ===================== QUICK ACTIONS =====================
        _buildQuickActions(),
        const SizedBox(height: 20),
      ],
    );
  }

  // ===================== ERROR STATE =====================
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                errorMessage.isNotEmpty
                    ? errorMessage
                    : 'Gagal memuat data dashboard',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF465940),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== HEADER ADMIN ======================
  Widget _buildHeader() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      color: const Color(0xFF465940),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 24,
            child: Icon(Icons.person, color: Color(0xFF465940), size: 32),
          ),
          const SizedBox(width: 14),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, Ini Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Admin@gmail.com",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              "Keluar",
              style: TextStyle(
                color: Color(0xFF465940),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  // ===================== DASHBOARD HEADER =====================
  Widget _buildDashboardHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard Admin",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xFF465940),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isLoading
                  ? "Memuat data sistem..."
                  : hasError
                      ? "Terjadi kesalahan"
                      : "Statistik & Ringkasan Sistem Sekolah",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: _loadDashboard,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF465940).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: const Color(0xFF465940),
                  size: 20,
                ),
              ),
              tooltip: "Refresh Data",
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF465940),
              child: const Icon(Icons.person, color: Colors.white, size: 26),
            ),
          ],
        ),
      ],
    );
  }

  // ===================== STATS GRID =====================
  Widget _buildStatsGrid() {
    final crossAxisCount = MediaQuery.of(context).size.width > 1200
        ? 4
        : MediaQuery.of(context).size.width > 800
            ? 3
            : MediaQuery.of(context).size.width > 500
                ? 2
                : 1;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: MediaQuery.of(context).size.width > 1200 ? 2.25 : 2.0,
      children: [
        _buildModernCard(
          icon: Icons.people_alt_rounded,
          title: "Total Siswa",
          value: stats?['total_siswa']?.toString() ?? '0',
          unit: "siswa",
        ),
        _buildModernCard(
          icon: Icons.person_pin_rounded,
          title: "Total Guru",
          value: stats?['total_guru']?.toString() ?? '0',
          unit: "guru",
        ),
        _buildModernCard(
          icon: Icons.family_restroom_rounded,
          title: "Total Orang Tua",
          value: stats?['total_orangtua']?.toString() ?? '0',
          unit: "orang",
        ),
        _buildModernCard(
          icon: Icons.meeting_room_rounded,
          title: "Total Kelas",
          value: stats?['total_kelas']?.toString() ?? '0',
          unit: "kelas",
        ),
      ],
    );
  }

  // ===================== MODERN CARD =====================
  Widget _buildModernCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF465940),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF465940),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== CHARTS SECTION =====================
  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Distribusi Siswa per Kelas",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF465940),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          height: 250,
          child: _buildBarChart(),
        ),
      ],
    );
  }

  // ===================== BAR CHART =====================
  Widget _buildBarChart() {
    if (chartData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 40,
              color: const Color(0xFF465940).withOpacity(0.3),
            ),
            const SizedBox(height: 10),
            const Text(
              "Data chart belum tersedia",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final maxValue = chartData.fold<int>(0, (max, item) {
      final value = (item['siswa'] ?? 0).toInt();
      return value > max ? value : max;
    });

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: chartData.map<Widget>((item) {
              final value = (item['siswa'] ?? 0).toDouble();
              final heightPercent = maxValue > 0 ? (value / maxValue) : 0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    width: 30,
                    height: heightPercent * 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF465940),
                          const Color(0xFF3B6B46),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['kelas']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 1,
          color: Colors.grey.shade200,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF465940),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Jumlah Siswa",
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  // ===================== RECENT ACTIVITIES =====================
  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Aktivitas Terbaru",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF465940),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3B6B46),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    "Lihat Semua",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 12),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ...List.generate(
          recentActivities.length > 4 ? 4 : recentActivities.length,
          (index) => _activityItem(recentActivities[index]),
        ),
      ],
    );
  }

  // ===================== ACTIVITY ITEM =====================
  Widget _activityItem(Map<String, dynamic> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF465940).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getIconFromString(activity['icon']?.toString()),
              color: const Color(0xFF465940),
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title']?.toString() ?? 'Aktivitas',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF465940),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['description']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            activity['time']?.toString() ?? '',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== QUICK ACTIONS =====================
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Aksi Cepat",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF465940),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _quickActionButton(
              icon: Icons.person_add_alt_1_rounded,
              label: "Tambah Siswa",
              onTap: () => handleMenu("Data Siswa"),
            ),
            const SizedBox(width: 15),
            _quickActionButton(
              icon: Icons.school_rounded,
              label: "Tambah Guru",
              onTap: () => handleMenu("Data Guru"),
            ),
          ],
        ),
      ],
    );
  }

  // ===================== QUICK ACTION BUTTON =====================
  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF465940).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF465940),
                  size: 22,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF465940),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== HELPER FUNCTIONS =====================
  IconData _getIconFromString(String? iconName) {
    switch (iconName) {
      case 'person_add':
        return Icons.person_add;
      case 'edit':
        return Icons.edit;
      case 'payment':
        return Icons.payment;
      case 'announcement':
        return Icons.announcement;
      case 'notifications':
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
  }
}