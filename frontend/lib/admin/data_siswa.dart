import 'package:flutter/material.dart';
import 'data_guru.dart';
import 'data_kelas.dart';
import 'data_orangTua.dart';
import 'dashboard_admin.dart';
import 'jadwal_pelajaran.dart';
import 'informasi_pembayaran.dart';
import 'package:frontend/widgets/sidebarAdmin.dart';

class DataSiswaPage extends StatefulWidget {
  const DataSiswaPage({super.key});

  @override
  State<DataSiswaPage> createState() => _DataSiswaPageState();
}

class _DataSiswaPageState extends State<DataSiswaPage> {
  // warna utama
  final Color primaryGreen = const Color(0xFF465940);

  // data master
  List<Map<String, String>> dataSiswa = [
    {
      "nama": "Anisa Putri",
      "ortu": "Budi Santoso",
      "agama": "Islam",
      "tgl": "12/07/2013",
      "kelas": "1A",
      "jk": "P",
      "ekskul": "Tari",
      "alamat": "Tiban",
    },
    {
      "nama": "Raka Pratama",
      "ortu": "Slamet Riyadi",
      "agama": "Islam",
      "tgl": "20/02/2013",
      "kelas": "1A",
      "jk": "L",
      "ekskul": "Futsal",
      "alamat": "Batu Aji",
    },
    {
      "nama": "Jessica",
      "ortu": "Albert",
      "agama": "Kristen",
      "tgl": "05/05/2012",
      "kelas": "2B",
      "jk": "P",
      "ekskul": "Music",
      "alamat": "Batam Center",
    },
    {
      "nama": "Melanie",
      "ortu": "Hendri",
      "agama": "Kristen",
      "tgl": "08/11/2012",
      "kelas": "2A",
      "jk": "P",
      "ekskul": "Dance",
      "alamat": "Nagoya",
    },
    {
      "nama": "Adit",
      "ortu": "Rahmat",
      "agama": "Islam",
      "tgl": "14/03/2012",
      "kelas": "3A",
      "jk": "L",
      "ekskul": "Basket",
      "alamat": "Batam Kota",
    },
  ];

  // filter state
  String filterNama = "";
  String? filterKelas; // null => semua
  String? filterJK; // "L","P" atau null

  // computed list berdasarkan filter
  List<Map<String, String>> get filteredList {
    return dataSiswa.where((s) {
      final matchesNama = filterNama.isEmpty ||
          s["nama"]!.toLowerCase().contains(filterNama.toLowerCase());
      final matchesKelas = filterKelas == null || s["kelas"] == filterKelas;
      final matchesJK = filterJK == null || s["jk"] == filterJK;
      return matchesNama && matchesKelas && matchesJK;
    }).toList();
  }

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

  // ================= POPUP: Tambah =================
  void showAddSiswaDialog() {
    final TextEditingController nama = TextEditingController();
    final TextEditingController ortu = TextEditingController();
    final TextEditingController agama = TextEditingController();
    final TextEditingController tgl = TextEditingController();
    final TextEditingController kelas = TextEditingController();
    final TextEditingController jk = TextEditingController();
    final TextEditingController ekskul = TextEditingController();
    final TextEditingController alamat = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Tambahkan Data Siswa"),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _inputField("Nama Siswa", nama),
                _inputField("Nama Orang Tua", ortu),
                _inputField("Agama", agama),
                _inputField("Tanggal Lahir", tgl),
                _inputField("Kelas", kelas),
                _dropdownField("Jenis Kelamin", ["L", "P"], jk),
                _inputField("Ekstrakulikuler", ekskul),
                _inputField("Alamat", alamat),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            onPressed: () {
              setState(() {
                dataSiswa.add({
                  "nama": nama.text,
                  "ortu": ortu.text,
                  "agama": agama.text,
                  "tgl": tgl.text,
                  "kelas": kelas.text,
                  "jk": jk.text,
                  "ekskul": ekskul.text,
                  "alamat": alamat.text,
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

  // ================= POPUP: Edit =================
  void showEditSiswaDialog(int dataIndexInFiltered) {
    // convert index in filteredList -> index in dataSiswa
    final siswa = filteredList[dataIndexInFiltered];
    final realIndex = dataSiswa.indexOf(siswa);

    final TextEditingController nama = TextEditingController(text: siswa["nama"]);
    final TextEditingController ortu = TextEditingController(text: siswa["ortu"]);
    final TextEditingController agama = TextEditingController(text: siswa["agama"]);
    final TextEditingController tgl = TextEditingController(text: siswa["tgl"]);
    final TextEditingController kelas = TextEditingController(text: siswa["kelas"]);
    final TextEditingController jk = TextEditingController(text: siswa["jk"]);
    final TextEditingController ekskul = TextEditingController(text: siswa["ekskul"]);
    final TextEditingController alamat = TextEditingController(text: siswa["alamat"]);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit Data Siswa"),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _inputField("Nama Siswa", nama),
                _inputField("Nama Orang Tua", ortu),
                _inputField("Agama", agama),
                _inputField("Tanggal Lahir", tgl),
                _inputField("Kelas", kelas),
                _dropdownField("Jenis Kelamin", ["L", "P"], jk),
                _inputField("Ekstrakulikuler", ekskul),
                _inputField("Alamat", alamat),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            onPressed: () {
              setState(() {
                dataSiswa[realIndex] = {
                  "nama": nama.text,
                  "ortu": ortu.text,
                  "agama": agama.text,
                  "tgl": tgl.text,
                  "kelas": kelas.text,
                  "jk": jk.text,
                  "ekskul": ekskul.text,
                  "alamat": alamat.text,
                };
              });
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  // ================= POPUP: Hapus =================
  void showDeleteSiswaDialog(int dataIndexInFiltered) {
    final siswa = filteredList[dataIndexInFiltered];
    final realIndex = dataSiswa.indexOf(siswa);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hapus Data"),
        content: Text("Apakah anda yakin ingin menghapus ${siswa['nama']} ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () {
              setState(() {
                dataSiswa.removeAt(realIndex);
              });
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // ================= POPUP: Filter =================
  void showFilterDialog() {
    final TextEditingController namaCtrl = TextEditingController(text: filterNama);
    String? kelasTmp = filterKelas;
    String? jkTmp = filterJK;

    final kelasOptions = <String>{
      ...dataSiswa.map((s) => s["kelas"]!).toSet(),
    }.toList()
      ..sort();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Filter Data Siswa"),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _inputField("Cari Nama (kosong = semua)", namaCtrl),
              const SizedBox(height: 8),
              // kelas dropdown
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: kelasTmp,
                      decoration: InputDecoration(
                        labelText: "Kelas",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: [null, ...kelasOptions].map((k) {
                        return DropdownMenuItem<String?>(
                          value: k,
                          child: Text(k ?? "Semua"),
                        );
                      }).toList(),
                      onChanged: (v) => kelasTmp = v,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: jkTmp,
                      decoration: InputDecoration(
                        labelText: "Jenis Kelamin",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text("Semua")),
                        DropdownMenuItem(value: "L", child: Text("Laki-laki")),
                        DropdownMenuItem(value: "P", child: Text("Perempuan")),
                      ],
                      onChanged: (v) => jkTmp = v,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                filterNama = "";
                filterKelas = null;
                filterJK = null;
              });
              Navigator.pop(context);
            },
            child: const Text("Reset"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            onPressed: () {
              setState(() {
                filterNama = namaCtrl.text.trim();
                filterKelas = kelasTmp;
                filterJK = jkTmp;
              });
              Navigator.pop(context);
            },
            child: const Text("Terapkan"),
          ),
        ],
      ),
    );
  }

  // ================== BUILD UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF0),
      body: Row(
        children: [
          SidebarAdmin(onMenuSelected: handleMenu),

          // MAIN CONTENT
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // header small (admin)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: primaryGreen,
                                  child: const Icon(Icons.person, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Halo, Ini Admin",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      "Admin@gmail.com",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: showFilterDialog,
                                  icon: const Icon(Icons.filter_list, color: Colors.black87),
                                  label: const Text("Filter", style: TextStyle(color: Colors.black87)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    side: BorderSide(color: Colors.black.withOpacity(0.15)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: showAddSiswaDialog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGreen,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text("+ Tambahkan Data", style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    // contoh tombol keluar atau fungsi lain
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    side: BorderSide(color: Colors.black.withOpacity(0.06)),
                                  ),
                                  child: Text("Keluar", style: TextStyle(color: primaryGreen)),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        const Text(
                          "Data Siswa",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF465940),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.black12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(2, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // informasi filter aktif
                                if (filterNama.isNotEmpty || filterKelas != null || filterJK != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.info_outline, size: 16),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            "Filter aktif: " +
                                                [
                                                  if (filterNama.isNotEmpty) "Nama contains '$filterNama'",
                                                  if (filterKelas != null) "Kelas: $filterKelas",
                                                  if (filterJK != null) "JK: $filterJK"
                                                ].join(" • "),
                                            style: TextStyle(color: Colors.grey.shade700),
                                          ),
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              filterNama = "";
                                              filterKelas = null;
                                              filterJK = null;
                                            });
                                          },
                                          child: const Text("Hapus Filter"),
                                        )
                                      ],
                                    ),
                                  ),

                                // tabel
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 200),
                                      child: SingleChildScrollView(
                                        child: DataTable(
                                          columnSpacing: 28,
                                          headingRowHeight: 48,
                                          dataRowHeight: 56,
                                          headingRowColor: MaterialStateProperty.all(const Color(0xFFFDFBF0)),
                                          headingTextStyle: TextStyle(
                                              fontWeight: FontWeight.bold, color: primaryGreen),
                                          dataTextStyle: const TextStyle(color: Colors.black87),
                                          columns: const [
                                            DataColumn(label: Text("Nama Siswa")),
                                            DataColumn(label: Text("Nama Orang Tua")),
                                            DataColumn(label: Text("Agama")),
                                            DataColumn(label: Text("Tanggal Lahir")),
                                            DataColumn(label: Text("Kelas")),
                                            DataColumn(label: Text("Jenis Kelamin")),
                                            DataColumn(label: Text("Ekstrakulikuler")),
                                            DataColumn(label: Text("Alamat")),
                                            DataColumn(label: Text("Aksi")),
                                          ],
                                          rows: List.generate(filteredList.length, (index) {
                                            final s = filteredList[index];
                                            return DataRow(cells: [
                                              DataCell(Text(s["nama"]!)),
                                              DataCell(Text(s["ortu"]!)),
                                              DataCell(Text(s["agama"]!)),
                                              DataCell(Text(s["tgl"]!)),
                                              DataCell(Text(s["kelas"]!)),
                                              DataCell(Text(s["jk"]! == "L" ? "Laki-laki" : "Perempuan")),
                                              DataCell(Text(s["ekskul"]!)),
                                              DataCell(Text(s["alamat"]!)),
                                              DataCell(Row(
                                                children: [
                                                  IconButton(
                                                    tooltip: "Edit",
                                                    onPressed: () => showEditSiswaDialog(index),
                                                    icon: Icon(Icons.edit, color: Colors.green.shade700, size: 20),
                                                  ),
                                                  IconButton(
                                                    tooltip: "Hapus",
                                                    onPressed: () => showDeleteSiswaDialog(index),
                                                    icon: Icon(Icons.delete, color: Colors.red.shade700, size: 20),
                                                  ),
                                                ],
                                              )),
                                            ]);
                                          }),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER ADMIN =================
  Widget _buildHeader() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: primaryGreen,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
      ),
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

  // ================= HELPERS: input field & dropdown =================
  Widget _inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _dropdownField(String label, List<String> options, TextEditingController controller) {
    String? current = controller.text.isEmpty ? null : controller.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: current,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: (v) => controller.text = v ?? "",
      ),
    );
  }
}
