import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dashboard_orangtua.dart';
import 'jadwal.dart';
import 'pengumuman.dart';
import 'pembayaran.dart';
import 'profil.dart';
import 'package:frontend/auth/login.dart';

class PerizinanPage extends StatefulWidget {
  const PerizinanPage({super.key});

  @override
  State<PerizinanPage> createState() => _PerizinanPageState();
}

class _PerizinanPageState extends State<PerizinanPage> {
  final _formKey = GlobalKey<FormState>();
  String? _jenisIzin = 'Sakit';
  DateTime? _tanggal;
  final _alasanController = TextEditingController();
  File? _bukti;
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;
  int _selectedIndex = 1;

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _pilihFotoGaleri() async {
    final XFile? picked =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _bukti = File(picked.path));
  }

  Future<void> _kirimIzin() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih tanggal izin terlebih dahulu")),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Permohonan izin berhasil dikirim")),
    );

    _formKey.currentState!.reset();
    setState(() {
      _tanggal = null;
      _bukti = null;
      _jenisIzin = 'Sakit';
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
        targetPage = const PerizinanPage();
        break;
      case 2:
        targetPage = JadwalPage();
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

  @override
  Widget build(BuildContext context) {
    const greenColor = Color(0xFF465940);
    const backgroundColor = Color(0xFFFDFBF0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: greenColor),
        title: const Text(
          "Formulir Perizinan",
          style: TextStyle(
            color: greenColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: greenColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tidak ada notifikasi baru")),
              );
            },
          ),
        ],
      ),

      drawer: Drawer(
        backgroundColor: backgroundColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: greenColor),
              child: Center(
                child: Text("Menu EduConnect",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
            _drawerItem(Icons.home, "Halaman Utama", () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => DashboardPage()));
            }),
            _drawerItem(Icons.home, "Agenda Sekolah", () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => DashboardPage()));
            }),
            _drawerItem(Icons.assignment_turned_in, "Perizinan", () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const PerizinanPage()));
            }),
            _drawerItem(Icons.calendar_month, "Jadwal Pelajaran", () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => JadwalPage()));
            }),
            _drawerItem(Icons.campaign, "Pengumuman", () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => PengumumanPage()));
            }),
            _drawerItem(Icons.payment, "Pembayaran", () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => RincianPembayaranPage()));
            }),
            _drawerItem(Icons.person, "Profil", () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => ProfilPage()));
            }),
            const Divider(),
            _drawerItem(Icons.logout, "Keluar", () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LoginPage()));
            }, color: Colors.red),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: Form(
            key: _formKey,
            child: Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ajukan Izin Anda",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: greenColor,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Jenis Izin
                    const Text("Jenis Izin",
                        style: TextStyle(color: greenColor, fontSize: 15)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _jenisIzin,
                      decoration: _inputDecoration(),
                      items: const [
                        DropdownMenuItem(value: "Sakit", child: Text("Sakit")),
                        DropdownMenuItem(
                            value: "Acara Keluarga",
                            child: Text("Acara Keluarga")),
                        DropdownMenuItem(
                            value: "Lainnya", child: Text("Lainnya")),
                      ],
                      onChanged: (value) => setState(() => _jenisIzin = value),
                    ),
                    const SizedBox(height: 16),

                    // Tanggal
                    const Text("Tanggal Izin",
                        style: TextStyle(color: greenColor, fontSize: 15)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pilihTanggal,
                      child: InputDecorator(
                        decoration: _inputDecoration(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _tanggal == null
                                  ? "Pilih tanggal..."
                                  : "${_tanggal!.day}/${_tanggal!.month}/${_tanggal!.year}",
                              style: const TextStyle(fontSize: 15),
                            ),
                            const Icon(Icons.calendar_today, color: greenColor),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Alasan
                    const Text("Alasan",
                        style: TextStyle(color: greenColor, fontSize: 15)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _alasanController,
                      maxLines: 3,
                      decoration: _inputDecoration(hint: "Tulis alasan izin..."),
                      validator: (value) =>
                          value == null || value.isEmpty
                              ? "Alasan wajib diisi"
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // Bukti Perizinan
                    const Text("Bukti Perizinan",
                        style: TextStyle(color: greenColor, fontSize: 15)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pilihFotoGaleri,
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: greenColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: greenColor.withOpacity(0.5)),
                        ),
                        child: _bukti == null
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.upload, color: greenColor, size: 40),
                                    SizedBox(height: 8),
                                    Text(
                                      "Upload Bukti Izin",
                                      style: TextStyle(
                                          color: greenColor,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_bukti!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Kirim
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _kirimIzin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "Kirim Permohonan",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Halaman Utama'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in), label: 'Perizinan'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Jadwal'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Pembayaran'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    const greenColor = Color(0xFF465940);
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: greenColor.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF465940)),
      title: Text(title, style: TextStyle(color: color ?? Colors.black87)),
      onTap: onTap,
    );
  }
}
