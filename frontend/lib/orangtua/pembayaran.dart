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
  late String selectedMonth;
  late String selectedYear;
  DateTime? selectedDate;
  List<_PaymentItem> items = [];
  int totalBayar = 0;
  bool loading = true;
  final Color greenColor = const Color(0xFF465940);
  final Color backgroundColor = const Color(0xFFFDFBF0);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month);
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

  // ========== DATE PICKER ==========
  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        int tempYear = selectedDate?.year ?? now.year;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              padding: const EdgeInsets.all(20),
              height:
                  MediaQuery.of(context).size.height * 0.5, // 50% dari layar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilih Periode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: greenColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Tahun Selector
                  Container(
                    decoration: BoxDecoration(
                      color: greenColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: greenColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: greenColor),
                          onPressed: () {
                            setDialogState(() {
                              tempYear--;
                            });
                          },
                        ),
                        Text(
                          tempYear.toString(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: greenColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right, color: greenColor),
                          onPressed: () {
                            setDialogState(() {
                              tempYear++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Label Bulan
                  Text(
                    'Pilih Bulan:',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),

                  const SizedBox(height: 10),

                  // Grid Bulan - PAKAI EXPANDED DENGAN TEPAT
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.8,
                          ),
                      itemCount: months.length,
                      itemBuilder: (context, index) {
                        final month = months[index];
                        final isSelected =
                            month == selectedMonth &&
                            tempYear.toString() == selectedYear;

                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              selectedDate = DateTime(tempYear, index + 1);
                              selectedMonth = month;
                              selectedYear = tempYear.toString();
                            });
                            fetchPembayaran();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? greenColor : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? greenColor
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                month,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tombol
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'SELESAI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
      drawer: const sidebarOrangtua(),
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
            // ========== BAGIAN INI YANG DIUBAH ==========
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
                // GANTI DROPDOWN LAMA DENGAN TOMBOL DATE PICKER
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: greenColor, width: 1.5),
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
                        Icon(Icons.calendar_month, size: 18, color: greenColor),
                        const SizedBox(width: 6),
                        Text(
                          "$selectedMonth $selectedYear",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: greenColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: greenColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ========== SAMPAI SINI ==========
            const SizedBox(height: 16),

            // Info periode
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: greenColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: greenColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Menampilkan pembayaran untuk $selectedMonth $selectedYear",
                      style: TextStyle(fontSize: 12, color: greenColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Kartu Pembayaran
            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (items.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 60,
                      color: greenColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Tidak ada data pembayaran\nuntuk $selectedMonth $selectedYear",
                      style: TextStyle(color: greenColor, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
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
