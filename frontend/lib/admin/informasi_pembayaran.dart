import 'package:flutter/material.dart';
import 'data_guru.dart';
import 'data_kelas.dart';
import 'data_orangTua.dart';
import 'dashboard_admin.dart';
import 'jadwal_pelajaran.dart';
import 'data_siswa.dart';
import 'package:frontend/widgets/sidebarAdmin.dart';

import 'package:frontend/models/pembayaran_admin.dart';
import '../services/pembayaran_admin_service.dart';

class DataPembayaranPage extends StatefulWidget {
  const DataPembayaranPage({super.key});

  @override
  State<DataPembayaranPage> createState() => _DataPembayaranPageState();
}

class _DataPembayaranPageState extends State<DataPembayaranPage> {
  final Color greenMain = const Color(0xFF465940);
  final Color creamBg = const Color(0xFFFDFBF0);

  // ================= DATA DARI BACKEND =================
  List<PembayaranAdmin> dataPembayaran = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await PembayaranAdminService.fetchAll();
      setState(() {
        dataPembayaran = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // ================= NAVIGASI (TIDAK DIUBAH) =================
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

  // ================= HAPUS DATA =================
  void hapusData(int id) async {
    await PembayaranAdminService.delete(id);
    loadData();
  }

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
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Kelola data informasi pembayaran",
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _buildTable(),
                          ),
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

  // ================= TABLE =================
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
          0: FixedColumnWidth(120),
          1: FixedColumnWidth(120),
          2: FixedColumnWidth(140),
          3: FixedColumnWidth(140),
          4: FixedColumnWidth(100),
        },
        children: [_headerRow(), ...dataPembayaran.map(_dataRow).toList()],
      ),
    );
  }

  TableRow _headerRow() {
    return TableRow(
      decoration: BoxDecoration(color: greenMain.withOpacity(0.15)),
      children: const [
        _CellHeader("ID Siswa"),
        _CellHeader("Bulan"),
        _CellHeader("Tahun"),
        _CellHeader("Total"),
        _CellHeader("Aksi"),
      ],
    );
  }

  TableRow _dataRow(PembayaranAdmin item) {
    return TableRow(
      children: [
        _cell(item.siswaId.toString()),
        _cell(item.bulan),
        _cell(item.tahunAjaran),
        _cell("Rp ${item.totalBayar}"),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => hapusData(item.id),
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
        children: const [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 24,
            child: Icon(Icons.person, color: Color(0xFF465940), size: 32),
          ),
          SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, Ini Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Admin@gmail.com", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _cell(String text) {
    return Padding(padding: const EdgeInsets.all(12), child: Text(text));
  }
}

// ================= CELL HEADER =================
class _CellHeader extends StatelessWidget {
  final String text;
  const _CellHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
