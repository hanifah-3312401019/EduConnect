import 'package:flutter/material.dart';
import 'data_guru.dart';
import 'data_kelas.dart';
import 'data_orangTua.dart';
import 'dashboard_admin.dart';
import 'jadwal_pelajaran.dart';
import 'data_siswa.dart';
import 'package:frontend/widgets/sidebarAdmin.dart';

class DataPembayaranPage extends StatefulWidget {
  const DataPembayaranPage({super.key});

  @override
  State<DataPembayaranPage> createState() => _DataPembayaranPageState();
}

class _DataPembayaranPageState extends State<DataPembayaranPage> {
  final Color greenMain = const Color(0xFF465940);
  final Color creamBg = const Color(0xFFFDFBF0);

  List<Map<String, String>> dataPembayaran = [
    {
      "id": "0012345679",
      "deskripsi": "SPP + Catering",
      "bulan": "Februari",
      "tahun": "2025/2026",
      "jumlah": "Rp. 800.000",
    },
    {
      "id": "0012345665",
      "deskripsi": "SPP + Ekskul",
      "bulan": "Agustus",
      "tahun": "2025/2026",
      "jumlah": "Rp. 700.000",
    },
    {
      "id": "0012345658",
      "deskripsi": "SPP + Catering",
      "bulan": "September",
      "tahun": "2025/2026",
      "jumlah": "Rp. 800.000",
    },
  ];

   // ================= NAVIGASI =================
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

  void tambahData() {
    final idC = TextEditingController();
    final deskC = TextEditingController();
    final bulanC = TextEditingController();
    final tahunC = TextEditingController();
    final jumlahC = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return _buildDialog(
          title: "Tambah Data Pembayaran",
          idC: idC,
          deskC: deskC,
          bulanC: bulanC,
          tahunC: tahunC,
          jumlahC: jumlahC,
          action: () {
            if (idC.text.isEmpty ||
                deskC.text.isEmpty ||
                bulanC.text.isEmpty ||
                tahunC.text.isEmpty ||
                jumlahC.text.isEmpty) return;

            setState(() {
              dataPembayaran.add({
                "id": idC.text.trim(),
                "deskripsi": deskC.text.trim(),
                "bulan": bulanC.text.trim(),
                "tahun": tahunC.text.trim(),
                "jumlah": jumlahC.text.trim(),
              });
            });

            Navigator.pop(ctx);
          },
        );
      },
    );
  }

  void editData(int index) {
    final item = dataPembayaran[index];
    final idC = TextEditingController(text: item["id"]);
    final deskC = TextEditingController(text: item["deskripsi"]);
    final bulanC = TextEditingController(text: item["bulan"]);
    final tahunC = TextEditingController(text: item["tahun"]);
    final jumlahC = TextEditingController(text: item["jumlah"]);

    showDialog(
      context: context,
      builder: (ctx) {
        return _buildDialog(
          title: "Edit Data Pembayaran",
          idC: idC,
          deskC: deskC,
          bulanC: bulanC,
          tahunC: tahunC,
          jumlahC: jumlahC,
          action: () {
            setState(() {
              dataPembayaran[index] = {
                "id": idC.text.trim(),
                "deskripsi": deskC.text.trim(),
                "bulan": bulanC.text.trim(),
                "tahun": tahunC.text.trim(),
                "jumlah": jumlahC.text.trim(),
              };
            });
            Navigator.pop(ctx);
          },
          isEdit: true,
        );
      },
    );
  }

  void hapusData(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Hapus Data"),
        content: const Text("Yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => dataPembayaran.removeAt(index));
              Navigator.pop(ctx);
            },
            child: const Text("Hapus"),
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
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: creamBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Data Pembayaran",
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Kelola data informasi pembayaran",
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: greenMain,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                icon:
                                    const Icon(Icons.add, color: Colors.white),
                                label: const Text(
                                  "Tambah Data",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: tambahData,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildTable(),
                        ],
                      ),
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

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: greenMain.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(color: greenMain.withOpacity(0.2)),
        ),
        columnWidths: const {
          0: FixedColumnWidth(130),
          1: FlexColumnWidth(),
          2: FixedColumnWidth(120),
          3: FixedColumnWidth(120),
          4: FixedColumnWidth(130),
          5: FixedColumnWidth(100),
        },
        children: [
          _headerRow(),
          ...List.generate(dataPembayaran.length,
              (i) => _dataRow(dataPembayaran[i], i)),
        ],
      ),
    );
  }

  TableRow _headerRow() {
    return TableRow(
      decoration: BoxDecoration(color: greenMain.withOpacity(0.15)),
      children: [
        _cellHeader("Id Siswa"),
        _cellHeader("Deskripsi"),
        _cellHeader("Bulan"),
        _cellHeader("Tahun"),
        _cellHeader("Jumlah"),
        _cellHeader("Aksi"),
      ],
    );
  }

  TableRow _dataRow(Map<String, String> item, int index) {
    return TableRow(
      children: [
        _cell(item["id"]!),
        _cell(item["deskripsi"]!),
        _cell(item["bulan"]!),
        _cell(item["tahun"]!),
        _cell(item["jumlah"]!),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => editData(index),
                icon: const Icon(Icons.edit, color: Colors.blue),
              ),
              IconButton(
                onPressed: () => hapusData(index),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text("Admin@gmail.com", style: TextStyle(color: Colors.white70)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              "Keluar",
              style: TextStyle(
                  color: Color(0xFF465940), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  AlertDialog _buildDialog({
    required String title,
    required TextEditingController idC,
    required TextEditingController deskC,
    required TextEditingController bulanC,
    required TextEditingController tahunC,
    required TextEditingController jumlahC,
    required VoidCallback action,
    bool isEdit = false,
  }) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _input("ID Siswa", idC),
            _input("Deskripsi", deskC),
            _input("Bulan", bulanC),
            _input("Tahun", tahunC),
            _input("Jumlah", jumlahC),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          onPressed: action,
          style: ElevatedButton.styleFrom(backgroundColor: greenMain),
          child: Text(isEdit ? "Update" : "Simpan"),
        ),
      ],
    );
  }

  Widget _input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  static Widget _cell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text),
    );
  }

  static Widget _cellHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
