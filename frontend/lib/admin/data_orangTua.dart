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

// DATA LOKAL SEMENTARA
List<Map<String, String>> dataOrangTua = [];

List<String> kelasList = [
  "Semua",
  "Kelas 1",
  "Kelas 2",
  "Kelas 3",
  "Kelas 4",
  "Kelas 5",
  "Kelas 6"
];

class DataOrangTuaPage extends StatefulWidget {
  const DataOrangTuaPage({super.key});

  @override
  State<DataOrangTuaPage> createState() => _DataOrangTuaPageState();
}

class _DataOrangTuaPageState extends State<DataOrangTuaPage> {
  String selectedFilter = "Semua";

  // =========================================================
  // FUNGSI POST API → TAMBAH ORANG TUA
  Future<bool> tambahOrangTua(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/orangtua/create");

      final res = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
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
  // FUNGSI GET API → AMBIL DATA ORANG TUA
  Future<void> loadDataOrangTua() async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/orangtua/list");

      final res = await http.get(url, headers: {
        "Accept": "application/json",
      });

      print("GET STATUS: ${res.statusCode}");

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = body["data"] as List;

        setState(() {
          dataOrangTua = list.map((d) {
            return {
              "nama": d["Nama"]?.toString() ?? "-",
              "email": d["Email"]?.toString() ?? "-",
              "telp": d["No_Telepon"]?.toString() ?? "-",
              "alamat": d["Alamat"]?.toString() ?? "-",
              "anak": "-",
              "kelas": "-",
            };
          }).toList();
        });
      } else {
        print("Gagal memuat data. Status: ${res.statusCode}");
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
    if (selectedFilter == "Semua") return dataOrangTua;
    return dataOrangTua.where((d) => d["kelas"] == selectedFilter).toList();
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
    String kelasDipilih = d["kelas"]!;

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
            onPressed: () {
              setState(() {
                dataOrangTua[index] = {
                  "nama": nama.text,
                  "telp": telp.text,
                  "email": email.text,
                  "alamat": alamat.text,
                  "anak": anak.text,
                  "kelas": kelasDipilih,
                };
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF465940)),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
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
            onPressed: () {
              setState(() => dataOrangTua.removeAt(index));
              Navigator.pop(context);
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
  // UI PAGE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color((0xFFFDFBF0)),
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
                    padding: const EdgeInsets.all(26.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Data Orang Tua",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF465940),
                              ),
                            ),

                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _filterData,
                                  icon: const Icon(Icons.filter_alt),
                                  label: const Text("Filter"),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF465940)),
                                  ),
                                ),

                                const SizedBox(width: 14),

                                ElevatedButton.icon(
                                  onPressed: _tambahData,
                                  icon: const Icon(Icons.add, color: Colors.white),
                                  label: const Text(
                                    "Tambahkan Data",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF465940),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Expanded(
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  headingRowColor:
                                      WidgetStateProperty.all(const Color(0xFF465940)),
                                  headingTextStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  dataRowColor: WidgetStateProperty.all(
                                    const Color(0xFFF9FAFB),
                                  ),
                                  columnSpacing: 40,
                                  columns: const [
                                    DataColumn(label: Text("Nama Orang Tua")),
                                    DataColumn(label: Text("Alamat")),
                                    DataColumn(label: Text("Email")),
                                    DataColumn(label: Text("No Telepon")),
                                    DataColumn(label: Text("Nama Anak")),
                                    DataColumn(label: Text("Kelas Anak")),
                                    DataColumn(label: Text("Aksi")),
                                  ],
                                  rows: List.generate(
                                    filteredData.length,
                                    (i) {
                                      final d = filteredData[i];
                                      return DataRow(cells: [
                                        DataCell(Text(d["nama"]!)),
                                        DataCell(Text(d["alamat"]!)),
                                        DataCell(Text(d["email"]!)),
                                        DataCell(Text(d["telp"]!)),
                                        DataCell(Text(d["anak"]!)),
                                        DataCell(Text(d["kelas"]!)),
                                        DataCell(Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.blue),
                                              onPressed: () => _editData(
                                                  dataOrangTua.indexOf(d)),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () => _deleteData(
                                                  dataOrangTua.indexOf(d)),
                                            ),
                                          ],
                                        )),
                                      ]);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
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
                    fontWeight: FontWeight.bold),
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
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
