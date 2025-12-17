import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dashboard_orangtua.dart';
import 'jadwal.dart';
import 'pengumuman.dart';
import 'profil.dart';
import 'package:frontend/auth/login.dart';
import 'package:frontend/env/api_base_url.dart';
import 'package:frontend/storage/auth_storage.dart';
import 'package:frontend/widgets/sidebarOrangtua.dart';
import 'package:frontend/widgets/notifikasi_widgets.dart';

class RincianPembayaranPage extends StatefulWidget {
  const RincianPembayaranPage({super.key});

  @override
  State<RincianPembayaranPage> createState() => _RincianPembayaranPageState();
}

class _RincianPembayaranPageState extends State<RincianPembayaranPage> {
  int _selectedIndex = 3;
  final List<String> months = const [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  final List<String> years = List.generate(6, (i) => (2024 + i).toString());
  late String selectedMonth;
  late String selectedYear;
  List<_PaymentItem> items = [];
  int totalBayar = 0;
  bool loading = true;
  final Color greenColor = const Color(0xFF465940);
  final Color backgroundColor = const Color(0xFFFDFBF0);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = months[now.month - 1];
    selectedYear = now.year.toString();
    _initPembayaran();
  }

  Future<void> _initPembayaran() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      debugPrint('TOKEN MASIH NULL, TUNGGU...');
      await Future.delayed(const Duration(milliseconds: 500));
      return _initPembayaran();
    }
    debugPrint('TOKEN SIAP, FETCH PEMBAYARAN');
    await fetchPembayaran();
  }

  Future<void> fetchPembayaran() async {
    setState(() => loading = true);
    final token = await AuthStorage.getToken();
    if (token == null) {
      debugPrint('TOKEN NULL - SKIP REQUEST');
      setState(() => loading = false);
      return;
    }

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/orangtua/pembayaran'
        '?bulan=$selectedMonth&tahun=$selectedYear',
      ),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    debugPrint('STATUS: ${response.statusCode}');
    debugPrint('BODY: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      setState(() {
        items = (json['items'] as List)
            .map((e) => _PaymentItem(e['nama'], 'Rp ${e['nominal']}'))
            .toList();
        totalBayar = json['total_bayar'];
        loading = false;
      });
    } else {
      loading = false;
      setState(() {});
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => JadwalPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PengumumanPage()),
        );
        break;
      case 3:
        // Tetap di halaman pembayaran
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfilPage()),
        );
        break;
    }
  }

  Widget _buildPaymentCard(
    String bulan,
    List<_PaymentItem> items,
    String total,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: greenColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bulan,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.nama, style: const TextStyle(color: Colors.white)),
                  Text(
                    item.nominal,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          const Divider(color: Colors.white54, thickness: 1, height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                total,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const sidebarOrangtua(), // Gunakan widget sidebar yang sudah ada
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF465940)),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.school, color: Color(0xFF465940)),
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
          child: Container(color: Colors.black.withOpacity(0.2), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul & Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Rincian Pembayaran",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF465940),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade400),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFF465940),
                      ),
                      const SizedBox(width: 4),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedMonth,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF465940),
                            size: 18,
                          ),
                          items: months
                              .map(
                                (month) => DropdownMenuItem(
                                  value: month,
                                  child: Text(
                                    month,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedMonth = value);
                              fetchPembayaran();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedYear,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF465940),
                            size: 18,
                          ),
                          items: years
                              .map(
                                (year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(
                                    year,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedYear = value);
                              fetchPembayaran();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Kartu Pembayaran
            if (loading)
              const Center(child: CircularProgressIndicator())
            else
              _buildPaymentCard(
                '$selectedMonth $selectedYear',
                items,
                'Rp $totalBayar',
              ),
            const SizedBox(height: 30),
            // Tata Cara Pembayaran
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: greenColor, width: 1.5),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.credit_card, color: Color(0xFF465940)),
                      SizedBox(width: 6),
                      Text(
                        "Tata Cara Pembayaran",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF465940),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "1. Pilih menu Transfer di Mobile/ATM Banking.\n"
                    "2. Masukkan No. Virtual Account: 123456789012\n"
                    "3. Periksa nama penerima: SD EduConnect\n"
                    "4. Masukkan nominal sesuai tagihan.\n"
                    "5. Simpan bukti transfer.",
                    style: TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
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
}

class _PaymentItem {
  final String nama;
  final String nominal;
  _PaymentItem(this.nama, this.nominal);
}
