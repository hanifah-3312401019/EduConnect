import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'edit_profil_anak.dart';
import 'edit_profil_orangtua.dart';
import 'dashboard_orangtua.dart';
import 'perizinan.dart';
import 'jadwal.dart';
import 'pengumuman.dart';
import 'pembayaran.dart';
import 'agenda.dart';
import 'package:frontend/auth/login.dart';
import 'package:frontend/env/api_base_url.dart';
import 'package:frontend/widgets/sidebarOrangtua.dart';
import 'package:frontend/widgets/NavbarOrangtua.dart';

String baseUrl = "http://localhost:8000/api";
const Color greenColor = Color(0xFF465940);
const Color backgroundColor = Color(0xFFFDFBF0);


class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  int _selectedIndex = 4; // Profil aktif
  Map<String, dynamic>? profil;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchProfil();
  }

  Future<void> fetchProfil() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/profil-new"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          profil = responseData;
          isLoading = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          profil = null;
          isLoading = false;
          errorMessage = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        profil = null;
        isLoading = false;
        errorMessage = "Koneksi error: $e";
      });
    }
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
    return Scaffold(
      backgroundColor: backgroundColor,
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
          IconButton(
            icon: const Icon(Icons.notifications_none, color: greenColor),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : profil == null || errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    errorMessage.isEmpty
                        ? "Tidak ada data profil"
                        : errorMessage,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: fetchProfil,
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header Profil
                    Container(
                      width: double.infinity,
                      color: greenColor,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              color: greenColor,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profil!["Nama"]?.toString() ?? 'Nama Orang Tua',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Status: Orang Tua",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildDataCard(
                            title: "Data Orang Tua",
                            fields: {
                              "Nama": profil!["Nama"]?.toString() ?? "-",
                              "No Telepon":
                                  profil!["No_Telepon"]?.toString() ?? "-",
                              "Email": profil!["Email"]?.toString() ?? "-",
                              "Alamat": profil!["Alamat"]?.toString() ?? "-",
                            },
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditOrangTuaPage(data: profil!),
                                ),
                              ).then((_) => fetchProfil());
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildDataCard(
                            title: "Data Anak",
                            fields: {
                              "Nama": profil!["nama_anak"]?.toString() ?? "-",
                              "Ekstrakulikuler":
                                  profil!["ekskul"]?.toString() ?? "-",
                              "Tanggal Lahir":
                                  profil!["tgl_lahir"]?.toString() ?? "-",
                              "Jenis Kelamin": profil!["jenis_kelamin"] == 'L'
                                  ? 'Laki-laki'
                                  : 'Perempuan',
                              "Agama": profil!["agama"]?.toString() ?? "-",
                              "Alamat":
                                  profil!["alamat_anak"]?.toString() ?? "-",
                            },
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditAnakPage(data: profil!),
                                ),
                              ).then((_) => fetchProfil());
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: NavbarOrangtua(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDataCard({
    required String title,
    required Map<String, String> fields,
    required VoidCallback onEdit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: greenColor, width: 1.8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...fields.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      e.key,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Text(": "),
                  Expanded(child: Text(e.value, softWrap: true)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: ElevatedButton(
              onPressed: onEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 10,
                ),
              ),
              child: const Text(
                "Edit Data",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
