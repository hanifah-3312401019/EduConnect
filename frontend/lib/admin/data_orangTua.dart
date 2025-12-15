import 'package:flutter/material.dart';
import 'dashboard_admin.dart';
import 'data_guru.dart';
import 'data_kelas.dart';
import 'data_siswa.dart';
import 'jadwal_pelajaran.dart';
import 'informasi_pembayaran.dart';
import 'package:frontend/widgets/sidebarAdmin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/env/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

// DATA LOKAL SEMENTARA
List<Map<String, String>> dataOrangTua = [];

int min(int a, int b) => a < b ? a : b;

List<String> kelasList = [
  "Semua",
  "Kelas 1A",
  "Kelas 1B",
  "Kelas 2A",
  "Kelas 2B",
  "Kelas 3A",
  "Kelas 3B",
  "Kelas 4A",
  "Kelas 4B",
  "Kelas 5A",
  "Kelas 5B",
  "Kelas 6A",
  "Kelas 6B"
];

class DataOrangTuaPage extends StatefulWidget {
  const DataOrangTuaPage({super.key});

  @override
  State<DataOrangTuaPage> createState() => _DataOrangTuaPageState();
}

class _DataOrangTuaPageState extends State<DataOrangTuaPage> {
  String selectedFilter = "Semua";
  int? _sortColumnIndex;
  bool _sortAscending = true;

  // =========================================================
  // FUNGSI UNTUK MENGAMBIL TOKEN
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // =========================================================
  // FUNGSI POST API → TAMBAH ORANG TUA
  Future<bool> tambahOrangTua(Map<String, dynamic> data) async {
  try {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/orangtua/create");
    final token = await _getToken(); // <-- AMBIL TOKEN
    
    if (token == null) {
      print("ERROR: Token tidak ditemukan");
      return false;
    }

    final res = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token", // <-- TAMBAHKAN INI
      },
      body: jsonEncode(data),
    );

    print("STATUS: ${res.statusCode}");
    print("BODY: ${res.body}");

    if (res.statusCode == 200 || res.statusCode == 201) {
      final resBody = jsonDecode(res.body);
      return resBody["success"] == true;
    }

    return false;
  } catch (e) {
    print("Error tambah orang tua: $e");
    return false;
  }
}

  // =========================================================
  // FUNGSI UPDATE API → UBAH DATA ORANG TUA
  Future<bool> updateOrangTua(String id, Map<String, dynamic> data) async {
  final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/orangtua/update/$id");
  final token = await _getToken(); // <-- TAMBAHKAN INI
  
  if (token == null) {
    print("ERROR: Token tidak ditemukan untuk update");
    return false;
  }

  final res = await http.put(
    url,
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer $token", // <-- TAMBAHKAN INI
    },
    body: jsonEncode(data),
  );

  print("UPDATE STATUS: ${res.statusCode}");
  print("UPDATE BODY: ${res.body}");

  return res.statusCode == 200;
}

  // =========================================================
  // FUNGSI DELETE API → HAPUS DATA ORANG TUA
  Future<bool> deleteOrangTua(String id) async {
  final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/orangtua/delete/$id");
  final token = await _getToken(); // <-- TAMBAHKAN INI
  
  if (token == null) {
    print("ERROR: Token tidak ditemukan untuk delete");
    return false;
  }

  final res = await http.delete(url, headers: {
    "Accept": "application/json",
    "Authorization": "Bearer $token", // <-- TAMBAHKAN INI
  });

  print("DELETE STATUS: ${res.statusCode}");
  print("DELETE RESPONSE: ${res.body}");

  return res.statusCode == 200;
}

  // =========================================================
  // FUNGSI GET API → AMBIL DATA ORANG TUA
  Future<void> loadDataOrangTua() async {
  try {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/orangtua/list");
    
    // AMBIL TOKEN
    final token = await _getToken();
    
    if (token == null || token.isEmpty) {
      print("ERROR: Token tidak ditemukan. Pastikan sudah login sebagai admin.");
      return;
    }

    print("Token yang digunakan: ${token.substring(0, min(20, token.length))}...");

    final res = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token", // <-- INI YANG PENTING
      },
    );

    print("GET STATUS: ${res.statusCode}");
    print("RESPONSE BODY: ${res.body}");

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      if (body['success'] == true) {
        final list = body["data"] as List;

        setState(() {
          dataOrangTua = list.map((d) {
            return {
              "id": d["OrangTua_Id"].toString(),
              "nama": d["Nama"]?.toString() ?? "-",
              "email": d["Email"]?.toString() ?? "-",
              "telp": d["No_Telepon"]?.toString() ?? "-",
              "alamat": d["Alamat"]?.toString() ?? "-",
              "anak": d["Anak"]?.toString() ?? "-",
              "kelas": d["Kelas"]?.toString() ?? "-",
            };
          }).toList();
        });
        print("Data berhasil dimuat: ${dataOrangTua.length} records");
      } else {
        print("API mengembalikan success: false - ${body['message']}");
      }
    } else {
      print("Gagal memuat data. Status: ${res.statusCode}");
      print("Response: ${res.body}");
    }
  } catch (e) {
    print("ERROR FETCH DATA ORANG TUA: $e");
  }
}

  @override
  void initState() {
    super.initState();
    loadDataOrangTua();
  }

  // =========================================================
  // FILTER TABLE
  List<Map<String, String>> get filteredData {
    List<Map<String, String>> result;

    if (selectedFilter == "Semua") {
      result = List.from(dataOrangTua);
    } else {
      // Filter dengan partial match (mencari "Kelas 1" di "Kelas 1A", "Kelas 1B", dll)
    result = dataOrangTua.where((d) {
      final kelasValue = d["kelas"] ?? "";
      return kelasValue.contains(selectedFilter);
    }).toList();
  }

    // Sorting jika diperlukan
    if (_sortColumnIndex != null) {
      result.sort((a, b) {
        final key = _getSortKey(_sortColumnIndex!);
        final aValue = a[key]?.toLowerCase() ?? '';
        final bValue = b[key]?.toLowerCase() ?? '';

        return _sortAscending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      });
    }

    return result;
  }

  String _getSortKey(int columnIndex) {
    switch (columnIndex) {
      case 0:
        return "nama";
      case 1:
        return "alamat";
      case 2:
        return "email";
      case 3:
        return "telp";
      case 4:
        return "anak";
      case 5:
        return "kelas";
      default:
        return "nama";
    }
  }

  // =========================================================
  // MODAL TAMBAH DATA
  void _tambahData() {
    final nama = TextEditingController();
    final telp = TextEditingController();
    final email = TextEditingController();
    final alamat = TextEditingController();
    final anak = TextEditingController();
    String kelasDipilih = "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Data Orang Tua"),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _input(nama, "Nama Orang Tua"),
              _input(telp, "Nomor Telepon"),
              _input(email, "Email"),
              _input(alamat, "Alamat"),
              _input(anak, "Nama Anak"),

              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: kelasDipilih.isEmpty ? null : kelasDipilih,
                decoration: _inputDecoration("Kelas Anak"),
                items: kelasList
                    .where((e) => e != "Semua")
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => kelasDipilih = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),

          // SIMPAN KE API
          ElevatedButton(
            onPressed: () async {
              final ok = await tambahOrangTua({
                "Nama": nama.text,
                "Email": email.text,
                "No_Telepon": telp.text,
                "Alamat": alamat.text,
              });

              if (ok) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Akun Orang Tua berhasil ditambahkan!")),
                );

                setState(() {
                  dataOrangTua.add({
                    "nama": nama.text,
                    "telp": telp.text,
                    "email": email.text,
                    "alamat": alamat.text,
                    "anak": anak.text,
                    "kelas": kelasDipilih,
                  });
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Gagal menambahkan data")),
                );
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: const Color(0xFF465940)),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // EDIT DATA
  void _editData(int index) {
    final d = dataOrangTua[index];

    final nama = TextEditingController(text: d["nama"]);
    final telp = TextEditingController(text: d["telp"]);
    final email = TextEditingController(text: d["email"]);
    final alamat = TextEditingController(text: d["alamat"]);
    final anak = TextEditingController(text: d["anak"]);
    String kelasDipilih = 
    kelasList.contains(d["kelas"]) ? d["kelas"]! : kelasList[1];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Data Orang Tua"),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _input(nama, "Nama Orang Tua"),
              _input(telp, "Nomor Telepon"),
              _input(email, "Email"),
              _input(alamat, "Alamat"),
              _input(anak, "Nama Anak"),

              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: kelasDipilih,
                decoration: _inputDecoration("Kelas Anak"),
                items: kelasList
                    .where((e) => e != "Semua")
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => kelasDipilih = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final id = d["id"]!;
              
              final success = await updateOrangTua(id, {
                "Nama": nama.text,
                "Email": email.text,
                "No_Telepon": telp.text,
                "Alamat": alamat.text,
                "Anak": anak.text,
                "Kelas": kelasDipilih,
              });
                
              if (success) {
                await loadDataOrangTua();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Data berhasil diperbarui!")),
               );
             }
           },
           child: const Text("Simpan"), 
          ),
        ],
      ),
    );
  }

  // =========================================================
  // DELETE DATA
  void _deleteData(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Data"),
        content: Text("Yakin ingin menghapus data ${dataOrangTua[index]['nama']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final id = dataOrangTua[index]["id"]!;

              final success = await deleteOrangTua(id);

              if (success) {
                await loadDataOrangTua();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Data berhasil dihapus")),
                  );
                }
              },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FILTER
  void _filterData() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Filter Berdasarkan Kelas"),
        content: DropdownButton<String>(
          value: selectedFilter,
          items: kelasList
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) {
            setState(() => selectedFilter = value!);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  // =========================================================
  // INPUT STYLE
  Widget _input(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        decoration: _inputDecoration(label),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
    );
  }

  // =========================================================
  // NAVIGASI MENU
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
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }

  // =========================================================
  // TABEL MODERN DENGAN STYLING
Widget _buildModernTable() {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.6, // Atur tinggi tetap
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView( // ← TAMBAHKAN INI UNTUK SCROLL VERTICAL
          scrollDirection: Axis.vertical,
          child: Container(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 100,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: DataTable(
                dividerThickness: 0,
                headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) => Colors.transparent,
                ),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.grey[100];
                    }
                    return Colors.transparent;
                  },
                ),
                headingTextStyle: const TextStyle(
                  color: Color(0xFF465940),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                dataTextStyle: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
                columnSpacing: 24,
                horizontalMargin: 16,
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: [
                  DataColumn(
                    label: _buildTableHeader("Nama Orang Tua", Icons.person),
                    onSort: (columnIndex, ascending) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                  ),
                  DataColumn(
                    label: _buildTableHeader("Alamat", Icons.location_on),
                    onSort: (columnIndex, ascending) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                  ),
                  DataColumn(
                    label: _buildTableHeader("Email", Icons.email),
                    onSort: (columnIndex, ascending) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                  ),
                  DataColumn(
                    label: _buildTableHeader("No Telepon", Icons.phone),
                    onSort: (columnIndex, ascending) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                  ),
                  DataColumn(
                    label: _buildTableHeader("Nama Anak", Icons.child_care),
                    onSort: (columnIndex, ascending) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                  ),
                  DataColumn(
                    label: _buildTableHeader("Kelas", Icons.school),
                    onSort: (columnIndex, ascending) {
                      setState(() {
                        _sortColumnIndex = columnIndex;
                        _sortAscending = ascending;
                      });
                    },
                  ),
                  const DataColumn(label: Text("Aksi")),
                ],
                rows: filteredData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final d = entry.value;

                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                backgroundColor: Color(0xFFE8F5E9),
                                child: Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Color(0xFF465940),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  d["nama"]!,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 150,
                          child: Text(
                            d["alamat"]!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                      DataCell(
                        Tooltip(
                          message: d["email"]!,
                          child: Row(
                            children: [
                              const Icon(Icons.email_outlined,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  d["email"]!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(d["telp"]!),
                          ],
                        ),
                      ),
                      DataCell(
                        Chip(
                          label: Text(
                            d["anak"]!,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.blue[50],
                          side: BorderSide.none,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getKelasColor(d["kelas"]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            d["kelas"]!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                              ),
                              onPressed: () => _editData(index),
                              splashRadius: 20,
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  size: 16,
                                  color: Colors.red,
                                ),
                              ),
                              onPressed: () => _deleteData(index),
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildTableHeader(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF465940)),
        const SizedBox(width: 6),
        Text(text),
      ]
    );
  }

  Color _getKelasColor(String kelas) {
    final colors = {
      "Kelas 1": const Color(0xFF4285F4), // Biru
      "Kelas 2": const Color(0xFF34A853), // Hijau
      "Kelas 3": const Color(0xFFFBBC05), // Kuning
      "Kelas 4": const Color(0xFFEA4335), // Merah
      "Kelas 5": const Color(0xFF8E44AD), // Ungu
      "Kelas 6": const Color(0xFF17A2B8), // Cyan
    };

    return colors[kelas] ?? const Color(0xFF465940);
  }

  // =========================================================
  // HEADER STATISTIK MODERN
  Widget _buildStatsHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              Icons.group,
              "Total Orang Tua",
              dataOrangTua.length.toString(),
              const Color(0xFF4285F4),
            ),
            _buildStatItem(
              Icons.child_care,
              "Total Anak",
              dataOrangTua
                  .fold(
                      0,
                      (sum, item) =>
                          sum + (item["anak"]!.isNotEmpty ? 1 : 0))
                  .toString(),
              const Color(0xFF34A853),
            ),
            _buildStatItem(
              Icons.filter_list,
              "Tertampil",
              "${filteredData.length} dari ${dataOrangTua.length}",
              const Color(0xFFFBBC05),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String title, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF465940),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // UI PAGE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          SidebarAdmin(onMenuSelected: handleMenu),

          // RIGHT SIDE
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Data Orang Tua",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF465940),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Total ${dataOrangTua.length} orang tua terdaftar",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedFilter,
                                      icon: const Icon(Icons.filter_alt, size: 20),
                                      items: kelasList.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Row(
                                            children: [
                                              Icon(
                                                value == "Semua"
                                                    ? Icons.all_inclusive
                                                    : Icons.school,
                                                size: 16,
                                                color: const Color(0xFF465940),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(value),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedFilter = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _tambahData,
                                  icon: const Icon(Icons.add, size: 20),
                                  label: const Text("Tambah Data"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF465940),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildStatsHeader(),
                        const SizedBox(height: 20),
                        Expanded(
                          child: _buildModernTable(),
                        ),
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

  // =========================================================
  // HEADER
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
          ),
        ],
      ),
    );
  }
}
