import 'package:flutter/material.dart';
import 'package:frontend/widgets/sidebarAdmin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/env/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_admin.dart';
import 'data_siswa.dart';
import 'data_orangTua.dart';
import 'data_kelas.dart';
import 'jadwal_pelajaran.dart';

class DataGuruPage extends StatefulWidget {
  const DataGuruPage({super.key});

  @override
  State<DataGuruPage> createState() => _DataGuruPageState();
}

class _DataGuruPageState extends State<DataGuruPage> {
  List<Map<String, dynamic>> guruList = [];
  bool isLoading = true;
  String? authToken;
  String? userRole;

  Future<void> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('token');
      userRole = prefs.getString('role');
    });
  }

  Future<void> loadDataGuru() async {
    setState(() => isLoading = true);
    
    if (authToken == null) {
      await loadAuthData();
    }
    
    if (userRole != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akses ditolak. Hanya admin yang dapat mengakses.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isLoading = false);
      return;
    }
    
    if (authToken == null || authToken!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token tidak valid. Silakan login kembali.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => isLoading = false);
      return;
    }
    
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/guru/list");
      
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $authToken",
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data["success"] == true) {
          final List<dynamic> list = data["data"] ?? [];
          
          // Urutkan data berdasarkan ID supaya tampil berurutan
          list.sort((a, b) {
            int idA = int.tryParse(a["Guru_Id"]?.toString() ?? "0") ?? 0;
            int idB = int.tryParse(b["Guru_Id"]?.toString() ?? "0") ?? 0;
            return idA.compareTo(idB);
          });
          
          setState(() {
            guruList = list.map<Map<String, dynamic>>((d) {
              return {
                "id": d["Guru_Id"]?.toString() ?? "",
                "nama": d["Nama"]?.toString() ?? "-",
                "nik": d["NIK"]?.toString() ?? "-",
                "email": d["Email"]?.toString() ?? "-",
                "status": "Data Guru",
                "kelas_nama": "Penugasan diatur di Data Kelas",
                "peran": "Guru",
                "created_at": d["created_at"]?.toString() ?? "-",
              };
            }).toList();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${data['message']}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sesi login telah berakhir. Silakan login kembali."),
            backgroundColor: Colors.red,
          ),
        );
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Akses ditolak. Hanya admin yang dapat mengakses."),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Server Error: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<bool> tambahGuru(Map<String, dynamic> data) async {
    try {
      if (authToken == null) await loadAuthData();
      
      final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/guru/create");
      
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json", 
          "Accept": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> resBody = jsonDecode(response.body);
        return resBody["success"] == true;
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sesi login telah berakhir. Silakan login kembali."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateGuru(String id, Map<String, dynamic> data) async {
    try {
      if (authToken == null) await loadAuthData();
      
      final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/guru/update/$id");
      
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json", 
          "Accept": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> resBody = jsonDecode(response.body);
        return resBody["success"] == true;
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sesi login telah berakhir. Silakan login kembali."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> deleteGuru(String id) async {
    try {
      if (authToken == null) await loadAuthData();
      
      final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/guru/delete/$id");
      
      final response = await http.delete(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $authToken",
        },
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 401) {
        return {
          "success": false, 
          "message": "Sesi login telah berakhir. Silakan login kembali."
        };
      }

      final Map<String, dynamic> resBody = jsonDecode(response.body);
      return {
        "success": resBody["success"] == true,
        "message": resBody["message"]?.toString() ?? "Terjadi kesalahan"
      };
    } catch (e) {
      return {"success": false, "message": "Koneksi error: $e"};
    }
  }

  Future<void> logout() async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/api/logout");
      await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $authToken",
        },
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('role');
      await prefs.remove('user_id');
      
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('role');
    }
  }

  @override
  void initState() {
    super.initState();
    loadAuthData().then((_) {
      loadDataGuru();
    });
  }

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
    }

    if (page != null && page.runtimeType != DataGuruPage) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }

  void showAddGuruDialog() {
    final nama = TextEditingController();
    final nik = TextEditingController();
    final email = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text(
            "Tambahkan Data Guru",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF465940)),
          ),
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _inputField("Nama Guru", nama, TextInputType.text),
                  _inputField("NIK", nik, TextInputType.text),
                  _inputField("Email", email, TextInputType.emailAddress),
                  
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.blue),
                        SizedBox(height: 5),
                        Text(
                          "Guru akan dibuat tanpa kelas. Penugasan kelas dapat dilakukan di halaman Data Kelas.",
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF465940),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                if (nama.text.isEmpty || nik.text.isEmpty || email.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Semua field wajib diisi"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (!RegExp(r'^[0-9]+$').hasMatch(nik.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("NIK harus berupa angka"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Format email tidak valid"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final Map<String, dynamic> data = {
                  "NIK": nik.text,
                  "Nama": nama.text,
                  "Email": email.text,
                };

                final ok = await tambahGuru(data);

                if (ok) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Akun Guru berhasil ditambahkan!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  await loadDataGuru();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Gagal menambahkan data. NIK atau Email mungkin sudah digunakan."),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void showEditGuruDialog(int index) {
    final guru = guruList[index];
    final nama = TextEditingController(text: guru["nama"]);
    final email = TextEditingController(text: guru["email"]);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text(
            "Edit Data Guru",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF465940)),
          ),
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _inputField("Nama Guru", nama, TextInputType.text),
                  _inputField("Email", email, TextInputType.emailAddress),
                  
                  const SizedBox(height: 10),
                  
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "NIK: ${guru["nik"]}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "(tidak dapat diubah)",
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.school, size: 16, color: Colors.orange),
                        SizedBox(height: 5),
                        Text(
                          "Penugasan kelas diatur di halaman Data Kelas",
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF465940),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                if (nama.text.isEmpty || email.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Nama dan Email wajib diisi"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Format email tidak valid"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final Map<String, dynamic> data = {
                  "Nama": nama.text,
                  "Email": email.text,
                };

                final ok = await updateGuru(guru["id"], data);

                if (ok) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Data Guru berhasil diperbarui!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  await loadDataGuru();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Gagal memperbarui data"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void showDeleteGuruDialog(int index) {
    final guru = guruList[index];

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Hapus Data Guru"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Apakah Anda yakin ingin menghapus ${guru["nama"]}?",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "PERHATIAN",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Data guru akan dihapus permanen. Pastikan guru ini tidak sedang ditugaskan di kelas mana pun.",
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final result = await deleteGuru(guru["id"]);
                Navigator.pop(context);
                
                if (result["success"] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result["message"]),
                      backgroundColor: Colors.green,
                    ),
                  );
                  await loadDataGuru();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result["message"]),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget guruCard(Map<String, dynamic> data, int index) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 9,
            offset: const Offset(1, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF465940).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "ID: ${data["id"]}",
              style: TextStyle(
                fontSize: 11,
                color: const Color(0xFF465940),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            data["nama"],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF465940),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          detailLine("NIK", data["nik"]),
          detailLine("Email", data["email"]),
          
          const SizedBox(height: 8),
          Flexible(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Penugasan kelas diatur di halaman Data Kelas",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => showEditGuruDialog(index),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.edit, size: 20, color: Colors.green.shade700),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => showDeleteGuruDialog(index),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.delete, size: 20, color: Colors.red.shade700),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, TextInputType keyboardType) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF465940),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 25,
            child: Icon(Icons.person, color: Color(0xFF465940), size: 32),
          ),
          const SizedBox(width: 14),

          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, Admin",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "Administrator",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),

          const Spacer(),

          GestureDetector(
            onTap: () async {
              await logout();
            },
            child: Container(
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
            ),
          ),
        ],
      ),
    );
  }

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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Data Guru",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF465940),
                          ),
                        ),
                        Text(
                          "Kelola data guru sekolah",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.8),
                        ),
                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total: ${guruList.length} guru",
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF465940),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 4,
                              ),
                              onPressed: showAddGuruDialog,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                "Tambahkan Data",
                                style: TextStyle(color: Colors.white, fontSize: 15),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        Expanded(
                          child: isLoading
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(color: Color(0xFF465940)),
                                      SizedBox(height: 15),
                                      Text(
                                        "Memuat data guru...",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : guruList.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.person_off, size: 60, color: Colors.grey.shade400),
                                          const SizedBox(height: 15),
                                          const Text(
                                            "Belum ada data guru",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          ElevatedButton(
                                            onPressed: loadDataGuru,
                                            child: const Text("Refresh"),
                                          ),
                                        ],
                                      ),
                                    )
                                  : GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 2.25,
                                        crossAxisSpacing: 22,
                                        mainAxisSpacing: 22,
                                      ),
                                      itemCount: guruList.length,
                                      itemBuilder: (_, index) => guruCard(guruList[index], index),
                                    ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}