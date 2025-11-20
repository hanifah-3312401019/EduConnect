import 'package:flutter/material.dart';
import 'package:frontend/widgets/sidebarAdmin.dart';
import 'data_guru.dart';
import 'data_siswa.dart';
import 'data_orangTua.dart';
import 'dashboard_admin.dart';
import 'jadwal_pelajaran.dart';
import 'informasi_pembayaran.dart';

class DataKelasPage extends StatefulWidget {
  const DataKelasPage({super.key});

  @override
  State<DataKelasPage> createState() => _DataKelasPageState();
}

class _DataKelasPageState extends State<DataKelasPage> {
  String tahunAjaran = "2024/2025";
  String kelasDipilih = "Kelas 1";

  List<Map<String, dynamic>> dataKelas = [
    {
      "wali": "Bu Tut Anggraini",
      "kelas": "Kelas 1A",
      "tahun": "2024/2025",
      "jumlah": 32,
      "siswa": ["Hanifah", "Melanie", "Jesica", "Windy", "Andi", "Beni"]
    },
    {
      "wali": "Bu Tut Anggraini",
      "kelas": "Kelas 1B",
      "tahun": "2024/2025",
      "jumlah": 30,
      "siswa": ["Rina", "Siti", "Tono", "Raka", "Fajar"]
    },
    {
      "wali": "Bu Tut Anggraini",
      "kelas": "Kelas 2A",
      "tahun": "2024/2025",
      "jumlah": 28,
      "siswa": ["Lia", "Dedi", "Risa", "Nico"]
    },
    {
      "wali": "Bu Tut Anggraini",
      "kelas": "Kelas 2B",
      "tahun": "2024/2025",
      "jumlah": 31,
      "siswa": ["Ika", "Hendra", "Tia", "Gilang", "Rama"]
    },
  ];

  final Set<int> _hovering = {};

  // ==========================================================
  //                       FILTERING
  // ==========================================================
  List<Map<String, dynamic>> get filteredData {
    return dataKelas.where((item) {
      bool matchTahun = item["tahun"] == tahunAjaran;
      bool matchKelas = item["kelas"].contains(kelasDipilih.split(" ")[1]);
      return matchTahun && matchKelas;
    }).toList();
  }

  // ==========================================================
  //                        TAMBAH KELAS
  // ==========================================================
  void _showTambahKelas() {
    final wali = TextEditingController();
    final kelas = TextEditingController();
    final tahun = TextEditingController(text: tahunAjaran);
    final jumlah = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Tambah Kelas"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _input(wali, "Nama Wali"),
            _input(kelas, "Nama Kelas"),
            _input(tahun, "Tahun Ajar"),
            _input(jumlah, "Jumlah Siswa", number: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                dataKelas.add({
                  "wali": wali.text,
                  "kelas": kelas.text,
                  "tahun": tahun.text,
                  "jumlah": int.tryParse(jumlah.text) ?? 0,
                  "siswa": [],
                });
              });
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  // ==========================================================
  //                        EDIT KELAS
  // ==========================================================
  void _showEditKelas(int index, Map<String, dynamic> data) {
    final wali = TextEditingController(text: data["wali"]);
    final kelas = TextEditingController(text: data["kelas"]);
    final tahun = TextEditingController(text: data["tahun"]);
    final jumlah = TextEditingController(text: data["jumlah"].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Kelas"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _input(wali, "Nama Wali"),
            _input(kelas, "Nama Kelas"),
            _input(tahun, "Tahun Ajar"),
            _input(jumlah, "Jumlah Siswa", number: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                dataKelas[index] = {
                  "wali": wali.text,
                  "kelas": kelas.text,
                  "tahun": tahun.text,
                  "jumlah": int.tryParse(jumlah.text) ?? 0,
                  "siswa": data["siswa"],
                };
              });
              Navigator.pop(context);
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  // ==========================================================
  //                        HAPUS KELAS
  // ==========================================================
  void _hapusKelas(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin ingin menghapus kelas ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              setState(() => dataKelas.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          )
        ],
      ),
    );
  }

  // ==========================================================
  //                         WIDGET UTAMA
  // ==========================================================
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
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Data Kelas",
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF465940))),
                        const SizedBox(height: 6),
                        const Text("Kelola Data Kelas dan Wali",
                            style: TextStyle(fontSize: 14, color: Colors.black87)),
                        const SizedBox(height: 18),

                        _buildFilterBar(),
                        const SizedBox(height: 18),

                        Expanded(
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.9,
                              crossAxisSpacing: 22,
                              mainAxisSpacing: 22,
                            ),
                            itemCount: filteredData.length,
                            itemBuilder: (context, index) {
                              final originalIndex = dataKelas.indexOf(filteredData[index]);
                              return _buildKelasCard(filteredData[index], originalIndex);
                            },
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

  // ==========================================================
  //                    KOMPONEN UI / REUSABLE
  // ==========================================================
  Widget _input(TextEditingController c, String label, {bool number = false}) {
    return TextField(
      controller: c,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label),
    );
  }

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
                style: TextStyle(
                    color: Color(0xFF465940), fontSize: 14, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox.shrink(),
        Row(
          children: [
            const Text("Pilih Tahun Ajaran : ", style: TextStyle(fontWeight: FontWeight.w600)),
            _dropdown(tahunAjaran, ["2023/2024", "2024/2025", "2025/2026"],
                (v) => setState(() => tahunAjaran = v!)),
            const SizedBox(width: 16),
            const Text("Pilih Kelas : ", style: TextStyle(fontWeight: FontWeight.w600)),
            _dropdown(kelasDipilih, ["Kelas 1", "Kelas 2", "Kelas 3"],
                (v) => setState(() => kelasDipilih = v!)),
            const SizedBox(width: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF465940),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              onPressed: _showTambahKelas,
              child: const Text("+ Tambah Kelas",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dropdown(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildKelasCard(Map<String, dynamic> data, int index) {
    final hovering = _hovering.contains(index);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering.add(index)),
      onExit: (_) => setState(() => _hovering.remove(index)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.identity()
          ..translate(0.0, hovering ? -6.0 : 0.0)
          ..scale(hovering ? 1.02 : 1.0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF465940).withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(hovering ? 0.10 : 0.05),
              blurRadius: hovering ? 14 : 8,
              offset: Offset(0, hovering ? 8 : 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                children: [
                  const Icon(Icons.person_pin, color: Color(0xFF465940), size: 18),
                  const SizedBox(width: 8),
                  Text(data["wali"],
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF465940))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B6B46), Color(0xFF465940)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(data["jumlah"].toString(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    const Icon(Icons.people, size: 14, color: Colors.white),
                  ],
                ),
              )
            ]),
            const SizedBox(height: 12),
            Text(data["kelas"], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text("Tahun ajar ${data["tahun"]}",
                style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),

            const Text("Daftar Siswa :", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),

            ..._buildSiswaPreview(data),
            const SizedBox(height: 6),
            Text("... dan ${data["jumlah"] - _previewCount(data)} siswa lainnya",
                style: const TextStyle(color: Colors.black54, fontSize: 13)),

            const Spacer(),

            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              _actionIconButton(Icons.edit,
                  onPressed: () => _showEditKelas(index, data)),
              const SizedBox(width: 10),
              _actionIconButton(Icons.delete,
                  color: Colors.redAccent,
                  onPressed: () => _hapusKelas(index)),
            ])
          ],
        ),
      ),
    );
  }

  int _previewCount(Map<String, dynamic> data) {
    final List list = data["siswa"] as List;
    return list.length >= 3 ? 3 : list.length;
  }

  List<Widget> _buildSiswaPreview(Map<String, dynamic> data) {
    final List list = data["siswa"] as List;
    final int limit = _previewCount(data);
    return List.generate(limit, (i) {
      return Row(
        children: [
          const Text("• ", style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(list[i],
                style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    });
  }

  Widget _actionIconButton(IconData icon,
      {Color? color, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color == null ? Colors.grey.shade100 : color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: color ?? const Color(0xFF465940)),
      ),
    );
  }

  // ==========================================================
  //                      NAVIGASI ADMIN
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
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }
}
