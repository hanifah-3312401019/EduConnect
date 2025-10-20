import 'package:flutter/material.dart';
import 'dashboard_orangtua.dart';
import 'jadwal.dart';
import 'profil.dart';
import 'pengumuman.dart';
import 'package:frontend/auth/login.dart'; // untuk tombol keluar

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

  final Map<String, List<_PaymentItem>> paymentData = {
    'Oktober 2025': [
      _PaymentItem('SPP Bulanan', 'Rp. 500.000'),
      _PaymentItem('Catering', 'Rp. 200.000'),
      _PaymentItem('Ekstrakurikuler', 'Rp. 150.000'),
    ],
    'September 2025': [
      _PaymentItem('SPP Bulanan', 'Rp. 500.000'),
      _PaymentItem('Catering', 'Rp. 180.000'),
      _PaymentItem('Ekstrakurikuler', 'Rp. 150.000'),
    ],
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = months[now.month - 1];
    selectedYear = now.year.toString();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
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
        targetPage = ProfilPage();
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
    final Color greenColor = const Color(0xFF465940);
    final Color backgroundColor = const Color(0xFFFDFBF0);

    String key = '$selectedMonth $selectedYear';
    List<_PaymentItem> items =
        paymentData[key] ??
        [
          _PaymentItem('SPP Bulanan', 'Rp. 500.000'),
          _PaymentItem('Catering', 'Rp. 200.000'),
          _PaymentItem('Ekstrakurikuler', 'Rp. 150.000'),
        ];
    paymentData.putIfAbsent(key, () => items);

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
            _drawerItem(Icons.campaign, "Pengumuman", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PengumumanPage()),
              );
            }),
            _drawerItem(
              Icons.payment,
              "Pembayaran",
              () {},
            ), // tetap di page ini
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
                    boxShadow: [
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
                            if (value != null)
                              setState(() => selectedMonth = value);
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
                            if (value != null)
                              setState(() => selectedYear = value);
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
            _buildPaymentCard(
              '$selectedMonth $selectedYear',
              items,
              'Rp. 850.000',
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
}

class _PaymentItem {
  final String nama;
  final String nominal;
  _PaymentItem(this.nama, this.nominal);
}
