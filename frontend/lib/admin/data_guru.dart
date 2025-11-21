import 'package:flutter/material.dart';
import 'package:frontend/widgets/sidebarAdmin.dart';

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
    }

    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }

  // LIST GURU
  List<Map<String, String>> guruList = [
    {
      "nama": "Dr. Ahmad Wijaya, M.Pd",
      "nik": "128546730987",
      "kelas": "1A",
      "email": "guru1@gmail.com"
    },
    {
      "nama": "Siti Rahayu, S.Pd",
      "nik": "128546730988",
      "kelas": "3C",
      "email": "guru2@gmail.com"
    },
    {
      "nama": "Rizki Pratama, S.Pd",
      "nik": "128546730989",
      "kelas": "2B",
      "email": "guru3@gmail.com"
    },
    {
      "nama": "Diana Sari, M.Pd",
      "nik": "128546730990",
      "kelas": "4A",
      "email": "guru4@gmail.com"
    },
  ];

  // ===================== POP UP TAMBAH =====================
  void showAddGuruDialog() {
    TextEditingController nama = TextEditingController();
    TextEditingController nik = TextEditingController();
    TextEditingController kelas = TextEditingController();
    TextEditingController email = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return _buildInputDialog(
          title: "Tambahkan Data Guru",
          nama: nama,
          nik: nik,
          kelas: kelas,
          email: email,
          onSave: () {
            setState(() {
              guruList.add({
                "nama": nama.text,
                "nik": nik.text,
                "kelas": kelas.text,
                "email": email.text
              });
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  // ===================== POP UP EDIT =====================
  void showEditGuruDialog(int index) {
    TextEditingController nama =
        TextEditingController(text: guruList[index]["nama"]);
    TextEditingController nik =
        TextEditingController(text: guruList[index]["nik"]);
    TextEditingController kelas =
        TextEditingController(text: guruList[index]["kelas"]);
    TextEditingController email =
        TextEditingController(text: guruList[index]["email"]);

    showDialog(
      context: context,
      builder: (_) {
        return _buildInputDialog(
          title: "Edit Data Guru",
          nama: nama,
          nik: nik,
          kelas: kelas,
          email: email,
          onSave: () {
            setState(() {
              guruList[index] = {
                "nama": nama.text,
                "nik": nik.text,
                "kelas": kelas.text,
                "email": email.text
              };
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  // ===================== POP UP HAPUS =====================
  void showDeleteGuruDialog(int index) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Hapus Data Guru"),
          content:
              Text("Apakah Anda yakin ingin menghapus ${guruList[index]["nama"]}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                setState(() => guruList.removeAt(index));
                Navigator.pop(context);
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ===================== UI UTAMA =====================
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
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

                        Align(
                          alignment: Alignment.topRight,
                          child: ElevatedButton.icon(
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
                        ),

                        const SizedBox(height: 25),

                        Expanded(
                          child: GridView.builder(
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

  // ===================== HEADER =====================
  Widget _buildHeader() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF465940),
        boxShadow: [
          BoxShadow(
              color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
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

  // ===================== CARD GURU =====================
  Widget guruCard(Map<String, String> data, int index) {
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
            Text(
              data["nama"]!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF465940),
              ),
            ),

            const SizedBox(height: 10),
            detailLine("NIK", data["nik"]!),
            detailLine("Kelas", data["kelas"]!),
            detailLine("Email", data["email"]!),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => showEditGuruDialog(index),
                  child:
                      Icon(Icons.edit, size: 21, color: Colors.green.shade700),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: () => showDeleteGuruDialog(index),
                  child:
                      Icon(Icons.delete, size: 21, color: Colors.red.shade700),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ===================== DETAIL LINE =====================
  Widget detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            "$label : ",
            style: TextStyle(
                fontWeight: FontWeight.w600, color: Colors.grey.shade800),
          ),
          Text(value, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  // ===================== DIALOG INPUT =====================
  Widget _buildInputDialog({
    required String title,
    required TextEditingController nama,
    required TextEditingController nik,
    required TextEditingController kelas,
    required TextEditingController email,
    required VoidCallback onSave,
  }) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF465940))),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _inputField("Nama Guru", nama),
            _inputField("NIK", nik),
            _inputField("Kelas", kelas),
            _inputField("Email", email),
          ],
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: onSave,
          child: const Text("Simpan", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
