import 'package:flutter/material.dart';
import 'package:frontend/widgets/sidebarAdmin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/env/api_base_url.dart';
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
  List<Map<String, dynamic>> kelasList = [];
  bool isLoading = true;

  Future<void> loadDataGuru() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/guru/list");
      final res = await http.get(url, headers: {
        "Accept": "application/json",
      });

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body["success"] == true) {
          final list = body["data"] as List? ?? [];
          setState(() {
            guruList = list.map((d) {
              return {
                "id": d["Guru_Id"]?.toString() ?? "",
                "nama": d["Nama"]?.toString() ?? "-",
                "nik": d["NIK"]?.toString() ?? "-",
                "email": d["Email"]?.toString() ?? "-",
                "kelas": d["Kelas"]?.toString() ?? "Belum ada kelas",
                "kelas_id": d["Kelas_Id"]?.toString() ?? "",
                "created_at": d["created_at"]?.toString() ?? "-",
              };
            }).toList();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${body['message']}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal memuat data guru"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadKelasList() async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/guru/kelas-list");
      final res = await http.get(url, headers: {
        "Accept": "application/json",
      });

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body["success"] == true) {
          final list = body["data"] as List? ?? [];
          setState(() {
            kelasList = list.map((d) {
              return {
                "id": d["Kelas_Id"]?.toString() ?? "",
                "nama": d["Nama_Kelas"]?.toString() ?? "",
                "guru_id": d["Guru_Id"]?.toString() ?? "",
                "guru_nama": d["guru"]?["Nama"]?.toString() ?? "Belum ada wali",
              };
            }).toList();
          });
        }
      }
    } catch (e) {}
  }

  Future<bool> tambahGuru(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/guru/create");
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode(data),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final resBody = jsonDecode(res.body);
        return resBody["success"] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateGuru(String id, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/guru/update/$id");
      final res = await http.put(
        url,
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode(data),
      );

      if (res.statusCode == 200) {
        final resBody = jsonDecode(res.body);
        return resBody["success"] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> deleteGuru(String id) async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/api/admin/guru/delete/$id");
      final res = await http.delete(
        url,
        headers: {"Accept": "application/json"},
      );

      final resBody = jsonDecode(res.body);
      return {
        "success": resBody["success"] == true,
        "message": resBody["message"]?.toString() ?? "Terjadi kesalahan"
      };
    } catch (e) {
      return {"success": false, "message": "Koneksi error"};
    }
  }

  @override
  void initState() {
    super.initState();
    loadDataGuru();
    loadKelasList();
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

    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }

  void showAddGuruDialog() {
    final nama = TextEditingController();
    final nik = TextEditingController();
    final email = TextEditingController();
    String selectedKelasId = "";

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
                  _inputField("Nama Guru", nama),
                  _inputField("NIK", nik),
                  _inputField("Email", email),
                  
                  const SizedBox(height: 15),
                  const Text(
                    "Pilih Kelas (Opsional)",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedKelasId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: "",
                        child: Text("Tidak ada kelas"),
                      ),
                      ...kelasList
                          .where((k) => k["guru_id"] == "" || k["guru_id"] == null)
                          .map((kelas) {
                            return DropdownMenuItem<String>(
                              value: kelas["id"],
                              child: Text(kelas["nama"]),
                            );
                          }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedKelasId = value ?? "";
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Kelas tersedia: ${kelasList.where((k) => k["guru_id"] == "" || k["guru_id"] == null).length}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
                      content: Text("Nama, NIK, dan Email wajib diisi"),
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

                if (selectedKelasId.isNotEmpty) {
                  data["Kelas_Id"] = selectedKelasId;
                }

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
                  await loadKelasList();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Gagal menambahkan data"),
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
    String selectedKelasId = guru["kelas_id"];

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
                  _inputField("Nama Guru", nama),
                  _inputField("Email", email),
                  
                  const SizedBox(height: 15),
                  const Text(
                    "Pilih Kelas",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedKelasId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: "",
                        child: Text("Tidak ada kelas"),
                      ),
                      ...kelasList
                          .where((k) => 
                            k["guru_id"] == "" || 
                            k["guru_id"] == null || 
                            k["guru_id"] == guru["id"]
                          )
                          .map((kelas) {
                            return DropdownMenuItem<String>(
                              value: kelas["id"],
                              child: Text(
                                "${kelas["nama"]} ${kelas["guru_id"] == guru["id"] ? "(Saat ini)" : ""}",
                                style: TextStyle(
                                  fontWeight: kelas["guru_id"] == guru["id"] 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedKelasId = value ?? "";
                      });
                    },
                  ),
                  
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "NIK: ${guru["nik"]} (tidak dapat diubah)",
                            style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                          ),
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
                  "Kelas_Id": selectedKelasId,
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
                  await loadKelasList();
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
              Text("Apakah Anda yakin ingin menghapus ${guru["nama"]}?"),
              const SizedBox(height: 10),
              if (guru["kelas"] != "Belum ada kelas")
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, size: 18, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Guru ini memiliki kelas: ${guru["kelas"]}",
                          style: TextStyle(color: Colors.orange.shade800, fontSize: 13),
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
                  await loadKelasList();
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
                                      itemBuilder: (_, index) {
                                        return guruCard(guruList[index], index);
                                      },
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

  Widget guruCard(Map<String, dynamic> data, int index) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
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
          children: [
            Row(
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
              ],
            ),
            
            const SizedBox(height: 8),
            
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

            const SizedBox(height: 10),
            detailLine("NIK", data["nik"]),
            detailLine("Email", data["email"]),
            Row(
              children: [
                const Text(
                  "Kelas: ",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                if (data["kelas"] != "Belum ada kelas")
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      data["kelas"],
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  Text(
                    "Belum ada kelas",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => showEditGuruDialog(index),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.edit, size: 18, color: Colors.green.shade700),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => showDeleteGuruDialog(index),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.delete, size: 18, color: Colors.red.shade700),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
                fontWeight: FontWeight.w600, color: Colors.grey.shade800),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}