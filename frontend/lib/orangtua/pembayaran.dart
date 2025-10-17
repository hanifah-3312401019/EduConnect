import 'package:flutter/material.dart';
import 'dashboard_orangtua.dart';
import 'jadwal.dart';
import 'profil.dart';
import 'pengumuman.dart';

class RincianPembayaranPage extends StatefulWidget {
  const RincianPembayaranPage({super.key});

  @override
  State<RincianPembayaranPage> createState() => _RincianPembayaranPageState();
}

class _RincianPembayaranPageState extends State<RincianPembayaranPage> {
  int _selectedIndex = 3;

  final List<String> months = [
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

  final List<String> years = List.generate(
    11,
    (index) => (2020 + index).toString(),
  );

  late String selectedMonth;
  late String selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = months[now.month - 1];
    selectedYear = now.year.toString();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Widget? targetPage;
    switch (index) {
      case 0:
        targetPage = const DashboardPage();
        break;
      case 1:
        targetPage = const JadwalPage();
        break;
      case 2:
        targetPage = const PengumumanPage(); // PASTIKAN CLASS INI ADA
        break;
      case 3:
        targetPage = const RincianPembayaranPage();
        break;
      case 4:
        targetPage = const ProfilPage();
        break;
    }

    if (targetPage != null && targetPage.runtimeType != runtimeType) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => targetPage!,
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const greenColor = Color(0xFF465940);
    const backgroundColor = Color(0xFFFDFBF0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: greenColor,
        automaticallyImplyLeading: false,
        title: const Text(
          "Rincian Pembayaran",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === FILTER BULAN / TAHUN (Dropdown) ===
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dropdown Bulan
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMonth,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: greenColor,
                        ),
                        items: months.map((month) {
                          return DropdownMenuItem(
                            value: month,
                            child: Text(
                              month,
                              style: const TextStyle(color: greenColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedMonth = value);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Dropdown Tahun
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedYear,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: greenColor,
                        ),
                        items: years.map((year) {
                          return DropdownMenuItem(
                            value: year,
                            child: Text(
                              year,
                              style: const TextStyle(color: greenColor),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedYear = value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // === KARTU PEMBAYARAN ===
            _buildPaymentCard("$selectedMonth $selectedYear", [
              _PaymentItem("SPP Bulanan", "Rp. 500.000"),
              _PaymentItem("Catering", "Rp. 200.000"),
              _PaymentItem("Ekstrakurikuler", "Rp. 150.000"),
            ], "Rp. 850.000"),

            const SizedBox(height: 30),

            // === TATA CARA PEMBAYARAN ===
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
                      Icon(Icons.menu_book, color: greenColor),
                      SizedBox(width: 6),
                      Text(
                        "Tata Cara Pembayaran",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: greenColor,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person), 
            label: 'Profil'
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    String bulan,
    List<_PaymentItem> items,
    String total,
  ) {
    const greenColor = Color(0xFF465940);
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
                  fontSize: 14,
                ),
              ),
              Text(
                total,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentItem {
  final String nama;
  final String nominal;
  const _PaymentItem(this.nama, this.nominal); // TAMBAHKAN CONST
}