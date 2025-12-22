import 'package:flutter/material.dart';
import 'package:frontend/widgets/sidebarAdmin.dart';
import 'package:frontend/admin/data_siswa.dart';
import 'package:frontend/admin/data_guru.dart';
import 'package:frontend/admin/data_orangTua.dart';
import 'package:frontend/admin/data_kelas.dart';
import 'package:frontend/admin/dashboard_admin.dart';
import 'package:frontend/admin/informasi_pembayaran.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/env/api_base_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JadwalPelajaranPage extends StatefulWidget {
  const JadwalPelajaranPage({super.key});

  @override
  State<JadwalPelajaranPage> createState() => _JadwalPelajaranPageState();
}

class _JadwalPelajaranPageState extends State<JadwalPelajaranPage> {
  // ===================== STATE VARIABLES =====================
  final Color greenMain = const Color(0xFF465940);
  final Color creamBg = const Color(0xFFFDFBF0);
  
  String? authToken;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  String adminName = "";
  String adminEmail = "";
  String _formatJam(String? jam) {
  if (jam == null || jam.isEmpty) return '';
  return jam.substring(0, 5); // ambil HH:MM
}

  // Data dari API
  List<Map<String, dynamic>> kelasList = [];
  List<Map<String, dynamic>> jadwalList = [];
  List<String> mataPelajaranList = [];
  List<String> hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
  
  // Filter
  String? selectedKelasId;
  String selectedHari = 'Senin';
  
  // Controller form
  final TextEditingController jamMulaiC = TextEditingController();
  final TextEditingController jamSelesaiC = TextEditingController();
  String? selectedMataPelajaran;
  
  Map<String, dynamic>? jadwalEdit;

  // ===================== INIT STATE =====================
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // ===================== INISIALISASI DATA =====================
  Future<void> _initializeData() async {
    await _loadToken();
    await _loadKelasList();
    await _loadMataPelajaranList();
    await _loadAdminData();
  }

  // ===================== LOAD TOKEN =====================
  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');
      setState(() {
        authToken = token;
      });
    } catch (e) {
      print('Error loading token: $e');
    }
  }

  // ===================== LOAD ADMIN DATA =====================
  Future<void> _loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      adminName = prefs.getString('nama') ?? "Admin";
      adminEmail = prefs.getString('email') ?? "admin@sekolah.com";
    });
  }

  // ===================== LOAD KELAS LIST =====================
  Future<void> _loadKelasList() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/kelas/list'),
        headers: {
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          setState(() {
            kelasList = List<Map<String, dynamic>>.from(json['data']);
            if (kelasList.isNotEmpty) {
              selectedKelasId = kelasList.first['Kelas_Id'].toString();
              _loadJadwalByKelas();
            }
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Gagal memuat data kelas: $e';
        isLoading = false;
      });
    }
  }

  // ===================== LOAD JADWAL BY KELAS =====================
  Future<void> _loadJadwalByKelas() async {
    if (selectedKelasId == null) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/jadwal/kelas/$selectedKelasId'),
        headers: {
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          jadwalList = List<Map<String, dynamic>>.from(json['data'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Gagal memuat jadwal';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Koneksi bermasalah: $e';
        isLoading = false;
      });
    }
  }

  // ===================== LOAD MATA PELAJARAN LIST =====================
  Future<void> _loadMataPelajaranList() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/mata-pelajaran/list'),
        headers: {
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          setState(() {
            mataPelajaranList = List<String>.from(json['data']);
            if (mataPelajaranList.isNotEmpty) {
              selectedMataPelajaran = mataPelajaranList.first;
            }
          });
        }
      }
    } catch (e) {
      print('Error loading mata pelajaran: $e');
    }
  }

  // ===================== CREATE JADWAL =====================
  Future<void> _createJadwal() async {
    if (selectedKelasId == null || selectedMataPelajaran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kelas dan mata pelajaran'))
      );
      return;
    }

    if (jamMulaiC.text.isEmpty || jamSelesaiC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi jam mulai dan jam selesai'))
      );
      return;
    }

    final Map<String, dynamic> data = {
      'Kelas_Id': selectedKelasId,
      'Hari': selectedHari,
      'Jam_Mulai': jamMulaiC.text,
      'Jam_Selesai': jamSelesaiC.text,
      'Mata_Pelajaran': selectedMataPelajaran,
    };

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/jadwal/create'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(data),
      );

      final json = jsonDecode(response.body);
      
      if (json['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(json['message']))
        );
        _loadJadwalByKelas();
        _clearForm();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(json['message'] ?? 'Gagal menambahkan jadwal'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'))
      );
    }
  }

  // ===================== UPDATE JADWAL =====================
  Future<void> _updateJadwal(String jadwalId) async {
    if (selectedKelasId == null || selectedMataPelajaran == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kelas dan mata pelajaran'))
      );
      return;
    }

    if (jamMulaiC.text.isEmpty || jamSelesaiC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi jam mulai dan jam selesai'))
      );
      return;
    }

    final Map<String, dynamic> data = {
      'Kelas_Id': selectedKelasId,
      'Hari': selectedHari,
      'Jam_Mulai': jamMulaiC.text,
      'Jam_Selesai': jamSelesaiC.text,
      'Mata_Pelajaran': selectedMataPelajaran,
    };

    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/jadwal/update/$jadwalId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(data),
      );

      final json = jsonDecode(response.body);
      
      if (json['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(json['message']))
        );
        _loadJadwalByKelas();
        _clearForm();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(json['message'] ?? 'Gagal memperbarui jadwal'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'))
      );
    }
  }

  // ===================== DELETE JADWAL =====================
  Future<void> _deleteJadwal(String jadwalId) async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Konfirmasi Hapus"),
          content: const Text("Yakin ingin menghapus jadwal ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal")
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(ctx);
                
                try {
                  final response = await http.delete(
                    Uri.parse('${ApiConfig.baseUrl}/api/admin/jadwal/delete/$jadwalId'),
                    headers: {
                      'Accept': 'application/json',
                      if (authToken != null) 'Authorization': 'Bearer $authToken',
                    },
                  );

                  final json = jsonDecode(response.body);
                  
                  if (json['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(json['message']))
                    );
                    _loadJadwalByKelas();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(json['message'] ?? 'Gagal menghapus jadwal'))
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'))
                  );
                }
              },
              child: const Text("Hapus"),
            )
          ],
        );
      },
    );
  }

  // ===================== CLEAR FORM =====================
  void _clearForm() {
    jamMulaiC.clear();
    jamSelesaiC.clear();
    selectedHari = 'Senin';
    selectedMataPelajaran = mataPelajaranList.isNotEmpty ? mataPelajaranList.first : null;
    jadwalEdit = null;
  }

  // ===================== SHOW ADD/EDIT DIALOG =====================
void _showJadwalDialog({Map<String, dynamic>? jadwalData}) {
  final String? dialogKelasId =
      jadwalData?['Kelas_Id']?.toString() ?? selectedKelasId;

  String dialogHari = jadwalData?['Hari'] ?? 'Senin';

  String? dialogMapel =
      jadwalData?['Mata_Pelajaran'] ??
      (mataPelajaranList.isNotEmpty ? mataPelajaranList.first : null);

  jamMulaiC.text = _formatJam(jadwalData?['Jam_Mulai']);
  jamSelesaiC.text = _formatJam(jadwalData?['Jam_Selesai']);

  showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, dialogSetState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(jadwalData != null ? "Edit Jadwal" : "Tambah Jadwal"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ===== KELAS =====
                  _labelledDropdown(
                    label: "Pilih Kelas",
                    value: kelasList.firstWhere(
                      (k) => k['Kelas_Id'].toString() == dialogKelasId,
                      orElse: () => kelasList.first,
                    )['Nama_Kelas'],
                    items: kelasList.map((k) => k['Nama_Kelas'] as String).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        final kelas = kelasList.firstWhere(
                          (k) => k['Nama_Kelas'] == v,
                        );
                        dialogSetState(() {
                          selectedKelasId = kelas['Kelas_Id'].toString();
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // ===== HARI =====
                  _labelledDropdown(
                    label: "Pilih Hari",
                    value: dialogHari,
                    items: hariList,
                    onChanged: (v) {
                      if (v != null) {
                        dialogSetState(() {
                          dialogHari = v;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // ===== JAM MULAI =====
                  TextField(
                    controller: jamMulaiC,
                    decoration: const InputDecoration(
                      labelText: "Jam Mulai (HH:MM)",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== JAM SELESAI =====
                  TextField(
                    controller: jamSelesaiC,
                    decoration: const InputDecoration(
                      labelText: "Jam Selesai (HH:MM)",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== MAPEL =====
                  _labelledDropdown(
                    label: "Mata Pelajaran",
                    value: dialogMapel,
                    items: mataPelajaranList,
                    onChanged: (v) {
                      if (v != null) {
                        dialogSetState(() {
                          dialogMapel = v;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: greenMain),
                onPressed: () {
                  selectedHari = dialogHari;
                  selectedMataPelajaran = dialogMapel;

                  if (jadwalData != null) {
                    _updateJadwal(jadwalData['Jadwal_Id'].toString());
                  } else {
                    _createJadwal();
                  }
                },
                child: Text(
                  jadwalData != null ? "Update" : "Simpan",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}


  // ===================== GET CURRENT KELAS NAMA =====================
  String? _getCurrentKelasNama() {
    if (selectedKelasId == null || kelasList.isEmpty) {
      return null;
    }
    
    try {
      final kelas = kelasList.firstWhere(
        (k) => k['Kelas_Id'].toString() == selectedKelasId,
        orElse: () => kelasList.first,
      );
      return kelas['Nama_Kelas'] as String;
    } catch (e) {
      return kelasList.first['Nama_Kelas'] as String;
    }
  }

  // ===================== BUILD KELAS DROPDOWN =====================
  Widget _buildKelasDropdown() {
    if (kelasList.isEmpty) {
      return DropdownButton<String>(
        value: null,
        underline: const SizedBox(),
        hint: const Text("Memuat..."),
        items: const [],
        onChanged: null,
      );
    }

    String? currentValue;
    
    try {
      if (selectedKelasId != null) {
        final selectedKelas = kelasList.firstWhere(
          (k) => k['Kelas_Id'].toString() == selectedKelasId,
          orElse: () => kelasList.first,
        );
        currentValue = selectedKelas['Nama_Kelas'] as String;
      } else {
        currentValue = kelasList.first['Nama_Kelas'] as String;
        selectedKelasId = kelasList.first['Kelas_Id'].toString();
      }
    } catch (e) {
      currentValue = kelasList.first['Nama_Kelas'] as String;
      selectedKelasId = kelasList.first['Kelas_Id'].toString();
    }

    return DropdownButton<String>(
      value: currentValue,
      underline: const SizedBox(),
      items: kelasList.map((k) {
        return DropdownMenuItem<String>(
          value: k['Nama_Kelas'] as String,
          child: Text(k['Nama_Kelas'] as String),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          try {
            final selected = kelasList.firstWhere(
              (k) => k['Nama_Kelas'] == newValue,
            );
            setState(() {
              selectedKelasId = selected['Kelas_Id'].toString();
              _loadJadwalByKelas();
            });
          } catch (e) {
            print('Error selecting kelas: $e');
          }
        }
      },
    );
  }

  // ===================== GET KELAS NAMA =====================
  String _getKelasNama() {
    if (kelasList.isEmpty || selectedKelasId == null) {
      return '-';
    }
    
    try {
      final kelas = kelasList.firstWhere(
        (k) => k['Kelas_Id'].toString() == selectedKelasId,
        orElse: () => {'Nama_Kelas': '-'},
      );
      return kelas['Nama_Kelas'] as String;
    } catch (e) {
      return '-';
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
      backgroundColor: creamBg,
      body: Row(
        children: [
          SidebarAdmin(onMenuSelected: handleMenu),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER
                        const Text(
                          "Jadwal Pelajaran",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF465940),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Kelola Jadwal Pelajaran Setiap Kelas",
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                        const SizedBox(height: 20),

                        // FILTER & TOMBOL TAMBAH
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // TOMBOL TAMBAH
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: greenMain,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () => _showJadwalDialog(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                child: Text(
                                  "+ Tambahkan Jadwal",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),

                            // FILTER KELAS
                            Row(
                              children: [
                                const Text(
                                  "Pilih Kelas : ",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: _buildKelasDropdown(),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // LOADING/ERROR STATE
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
                          Center(
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
                                    errorMessage,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadJadwalByKelas,
                                    child: const Text("Coba Lagi"),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          // TAMPILKAN JADWAL PER HARI
                          ...hariList.map((hari) {
                            final jadwalHari = jadwalList
                                .where((j) => j['Hari'] == hari)
                                .toList();
                            return _buildDayScheduleCard(hari, jadwalHari);
                          }).toList(),
                      ],
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

  // ===================== HEADER ADMIN =====================
  Widget _buildHeader() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      color: greenMain,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 24,
            child: Icon(Icons.person, color: greenMain, size: 32),
          ),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, $adminName!",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                adminEmail,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
    
        ],
      ),
    );
  }

  // ===================== CARD PER-HARI =====================
  Widget _buildDayScheduleCard(String hari, List<Map<String, dynamic>> jadwalHari) {
    return Container(
      margin: const EdgeInsets.only(bottom: 26),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: creamBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: greenMain.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LABEL HARI
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              hari,
              style: TextStyle(
                color: greenMain,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // JIKA KOSONG
          if (jadwalHari.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: greenMain),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Belum ada jadwal untuk hari $hari",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            )
          else
            // LIST JADWAL
            Column(
              children: jadwalHari.map((jadwal) {
                return _buildScheduleItem(jadwal);
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ===================== ITEM JADWAL =====================
  Widget _buildScheduleItem(Map<String, dynamic> jadwal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: greenMain.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          // WAKTU
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFECECEB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              jadwal['Jam_Format'] ?? '00.00 - 00.00',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // MATA PELAJARAN
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jadwal['Mata_Pelajaran'] ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Kelas: ${_getKelasNama()}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // TOMBOL EDIT
          IconButton(
            onPressed: () => _showJadwalDialog(jadwalData: jadwal),
            icon: Icon(Icons.edit, color: greenMain),
            tooltip: "Edit",
          ),

          // TOMBOL HAPUS
          IconButton(
            onPressed: () => _deleteJadwal(jadwal['Jadwal_Id'].toString()),
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: "Hapus",
          ),
        ],
      ),
    );
  }

  // ===================== HELPER: DROPDOWN DENGAN LABEL =====================
  Widget _labelledDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            isExpanded: true,
            items: items.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(e),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
