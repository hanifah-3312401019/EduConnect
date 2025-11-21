import 'package:flutter/material.dart';
import 'data_guru.dart';
import 'data_kelas.dart';
import 'data_siswa.dart';
import 'data_orangTua.dart';
import 'dashboard_admin.dart';
import 'informasi_pembayaran.dart';
import 'package:frontend/widgets/sidebarAdmin.dart';

class JadwalPelajaranPage extends StatefulWidget {
  const JadwalPelajaranPage({super.key});

  @override
  State<JadwalPelajaranPage> createState() => _JadwalPelajaranPageState();
}

class _JadwalPelajaranPageState extends State<JadwalPelajaranPage> {
  // Warna khas
  final Color greenMain = const Color(0xFF465940);
  final Color creamBg = const Color(0xFFFDFBF0);

  String selectedClass = "Kelas 1";

  // Struktur data: jadwalPerKelas[className][hari] = List<Map{jam,mapel,guru}]
  Map<String, Map<String, List<Map<String, String>>>> jadwalPerKelas = {
    "Kelas 1": {
      "Senin": [
        {
          "jam": "07.40 - 09.00",
          "mapel": "Matematika",
          "guru": "Bu Siska Amelia",
        },
        {
          "jam": "09.00 - 11.45",
          "mapel": "Agama",
          "guru": "Bu Siska Amelia",
        },
      ],
      "Selasa": [
        {
          "jam": "07.40 - 09.00",
          "mapel": "Pendidikan Jasmani & Rohani",
          "guru": "Pak Ahmadani Purba",
        },
        {
          "jam": "09.00 - 10.30",
          "mapel": "Bahasa Indonesia",
          "guru": "Bu Leni Rosalita",
        },
      ],
      "Rabu": [],
      "Kamis": [],
      "Jumat": [],
    },
    "Kelas 2": {
      "Senin": [
        {
          "jam": "07.40 - 09.00",
          "mapel": "Bahasa Inggris",
          "guru": "Bu Tut Anggraini",
        }
      ],
      "Selasa": [],
      "Rabu": [],
      "Kamis": [],
      "Jumat": [],
    },
    "Kelas 3": {
      "Senin": [],
      "Selasa": [],
      "Rabu": [],
      "Kamis": [],
      "Jumat": [],
    },
  };

  // Untuk dropdown hari
  final List<String> hariList = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat"];

  // ==========================================================
  // NAVIGASI ADMIN (mirip yang kamu pakai)
  // ==========================================================
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

  // ==========================================================
  // TAMBAH JADWAL
  // ==========================================================
  void _showTambahJadwal() {
    final TextEditingController jamC = TextEditingController();
    final TextEditingController mapelC = TextEditingController();
    final TextEditingController guruC = TextEditingController();
    String kelasTerpilih = selectedClass;
    String hariTerpilih = hariList.first;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Tambahkan Jadwal"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _labelledDropdown(
                  label: "Pilih Kelas",
                  value: kelasTerpilih,
                  items: jadwalPerKelas.keys.toList(),
                  onChanged: (v) => kelasTerpilih = v ?? kelasTerpilih,
                ),
                const SizedBox(height: 8),
                _labelledDropdown(
                  label: "Pilih Hari",
                  value: hariTerpilih,
                  items: hariList,
                  onChanged: (v) => hariTerpilih = v ?? hariTerpilih,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: jamC,
                  decoration: const InputDecoration(labelText: "Jam (contoh: 07.40 - 09.00)"),
                ),
                TextField(
                  controller: mapelC,
                  decoration: const InputDecoration(labelText: "Mata Pelajaran"),
                ),
                TextField(
                  controller: guruC,
                  decoration: const InputDecoration(labelText: "Guru Pengampu"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: greenMain),
              onPressed: () {
                if (jamC.text.trim().isEmpty ||
                    mapelC.text.trim().isEmpty ||
                    guruC.text.trim().isEmpty) {
                  // sederhana: jangan simpan kalau kosong
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Lengkapi semua kolom terlebih dahulu")));
                  return;
                }

                setState(() {
                  final target = jadwalPerKelas[kelasTerpilih]!;
                  if (!target.containsKey(hariTerpilih)) {
                    target[hariTerpilih] = [];
                  }
                  target[hariTerpilih]!.add({
                    "jam": jamC.text.trim(),
                    "mapel": mapelC.text.trim(),
                    "guru": guruC.text.trim(),
                  });
                });

                Navigator.pop(ctx);
              },
              child: const Text("Simpan"),
            )
          ],
        );
      },
    );
  }

  // ==========================================================
  // EDIT JADWAL (dayKey = hari, idx = posisi di list hari)
  // ==========================================================
  void _showEditJadwal(String kelas, String dayKey, int idx) {
    final item = jadwalPerKelas[kelas]![dayKey]![idx];
    final TextEditingController jamC = TextEditingController(text: item["jam"]);
    final TextEditingController mapelC = TextEditingController(text: item["mapel"]);
    final TextEditingController guruC = TextEditingController(text: item["guru"]);
    String hariTerpilih = dayKey;
    String kelasTerpilih = kelas;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Edit Jadwal"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _labelledDropdown(
                  label: "Pilih Kelas",
                  value: kelasTerpilih,
                  items: jadwalPerKelas.keys.toList(),
                  onChanged: (v) => kelasTerpilih = v ?? kelasTerpilih,
                ),
                const SizedBox(height: 8),
                _labelledDropdown(
                  label: "Pilih Hari",
                  value: hariTerpilih,
                  items: hariList,
                  onChanged: (v) => hariTerpilih = v ?? hariTerpilih,
                ),
                const SizedBox(height: 8),
                TextField(controller: jamC, decoration: const InputDecoration(labelText: "Jam")),
                TextField(controller: mapelC, decoration: const InputDecoration(labelText: "Mata Pelajaran")),
                TextField(controller: guruC, decoration: const InputDecoration(labelText: "Guru Pengampu")),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: greenMain),
              onPressed: () {
                if (jamC.text.trim().isEmpty ||
                    mapelC.text.trim().isEmpty ||
                    guruC.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Lengkapi semua kolom terlebih dahulu")));
                  return;
                }

                setState(() {
                  // hapus dari hari lama
                  final oldList = jadwalPerKelas[kelas]![dayKey]!;
                  final movingItem = Map<String, String>.from(oldList[idx]);
                  oldList.removeAt(idx);

                  // jika hari berubah, tambah ke hari baru di kelasTerpilih
                  final dest = jadwalPerKelas[kelasTerpilih]!;
                  if (!dest.containsKey(hariTerpilih)) dest[hariTerpilih] = [];
                  dest[hariTerpilih]!.add({
                    "jam": jamC.text.trim(),
                    "mapel": mapelC.text.trim(),
                    "guru": guruC.text.trim(),
                  });
                });

                Navigator.pop(ctx);
              },
              child: const Text("Update"),
            )
          ],
        );
      },
    );
  }

  // ==========================================================
  // HAPUS JADWAL
  // ==========================================================
  void _hapusJadwal(String kelas, String dayKey, int idx) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Konfirmasi Hapus"),
          content: const Text("Yakin ingin menghapus jadwal ini?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                setState(() {
                  jadwalPerKelas[kelas]![dayKey]!.removeAt(idx);
                });
                Navigator.pop(ctx);
              },
              child: const Text("Hapus"),
            )
          ],
        );
      },
    );
  }

  // ==========================================================
  // UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    final Map<String, List<Map<String, String>>> jadwalThisClass =
        jadwalPerKelas[selectedClass] ?? {};

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
                        const Text("Jadwal Pelajaran",
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text("Kelola Jadwal Pelajaran Setiap Kelas",
                            style: TextStyle(color: Colors.black54, fontSize: 14)),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: greenMain,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: _showTambahJadwal,
                              child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  child: Text("+ Tambahkan Jadwal", style: TextStyle(color: Colors.white))),
                            ),

                            Row(
                              children: [
                                const Text("Pilih Kelas : ",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedClass,
                                    underline: const SizedBox(),
                                    items: jadwalPerKelas.keys
                                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                                        .toList(),
                                    onChanged: (v) => setState(() => selectedClass = v!),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // tampilkan setiap hari -> card hari
                        ...hariList.map((hari) {
                          final listMapel = jadwalThisClass[hari] ?? [];
                          return _buildDayScheduleCard(hari, listMapel);
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Header sama gaya
  Widget _buildHeader() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      color: greenMain,
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
              Text("Halo, Ini Admin",
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              Text("Admin@gmail.com", style: TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: const Text("Keluar",
                style: TextStyle(color: Color(0xFF465940), fontSize: 14, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // Card per hari (warna cream)
  Widget _buildDayScheduleCard(String hari, List<Map<String, String>> list) {
    return Container(
      margin: const EdgeInsets.only(bottom: 26),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: creamBg, // card warna cream juga
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: greenMain.withOpacity(0.12)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // label hari (white pill)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Text(hari, style: TextStyle(color: greenMain, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 14),

          // jika kosong tampil hint
          if (list.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text("Belum ada jadwal untuk hari ini pada $selectedClass")),
                ],
              ),
            )
          else
            Column(
              children: List.generate(list.length, (i) {
                final item = list[i];
                return _buildScheduleItem(item, hari, i);
              }),
            ),
        ],
      ),
    );
  }

  // Card per mapel (warna white)
  Widget _buildScheduleItem(Map<String, String> data, String hari, int idx) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white, // mapel card putih agar kontras
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: greenMain.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          // jam
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFECECEB), borderRadius: BorderRadius.circular(12)),
            child: Text(data["jam"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),

          // mapel + guru
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(data["mapel"]!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(data["guru"]!, style: const TextStyle(color: Colors.black54)),
            ]),
          ),

          // edit
          TextButton(
            onPressed: () {
              _showEditJadwal(selectedClass, hari, idx);
            },
            child: const Text("Edit", style: TextStyle(color: Colors.black87)),
          ),

          // hapus
          TextButton(
            onPressed: () {
              _hapusJadwal(selectedClass, hari, idx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // helper: dropdown builder with label
  Widget _labelledDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white),
          child: DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
