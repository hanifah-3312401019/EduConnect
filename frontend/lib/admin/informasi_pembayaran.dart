import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/widgets/sidebarAdmin.dart';
import 'package:frontend/env/api_base_url.dart';

class DataPembayaranPage extends StatefulWidget {
  const DataPembayaranPage({super.key});

  @override
  State<DataPembayaranPage> createState() => _DataPembayaranPageState();
}

class _DataPembayaranPageState extends State<DataPembayaranPage> {
  final Color greenMain = const Color(0xFF465940);
  final Color creamBg = const Color(0xFFFDFBF0);

  List<Map<String, dynamic>> pembayaran = [];
  List<Map<String, dynamic>> ekstrakulikulerList = [];
  Map<int, int> biayaEkskulMap = {};
  bool loading = true;
  bool loadingEkskul = false;
  String errorMessage = '';
  String? authToken;
  String adminName = "";
  String adminEmail = "";

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    debugPrint("🎯 ===== MULAI INISIALISASI HALAMAN =====");
    await _loadAdminData();
    debugPrint("✅ Admin data loaded");

    await _loadToken();
    debugPrint("✅ Token loaded: ${authToken != null ? 'Ada' : 'Kosong'}");

    await _fetchEkstrakulikuler(); // Ambil data ekstrakurikuler DULU
    debugPrint("✅ Ekstrakulikuler loaded: ${ekstrakulikulerList.length} item");

    await fetchPembayaran(); // Baru ambil data pembayaran
    debugPrint("✅ Pembayaran loaded: ${pembayaran.length} item");
    debugPrint("===== INISIALISASI SELESAI =====\n");
  }

  Future<void> _loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      adminName = prefs.getString('nama') ?? "Admin";
      adminEmail = prefs.getString('email') ?? "admin@sekolah.com";
    });
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');

      if (!mounted) return;

      setState(() {
        authToken = token;
      });
    } catch (e) {
      debugPrint('Error loading token: $e');
    }
  }

  // ================================
  // AMBIL DATA EKSTRAKURIKULER - DIPERBAIKI
  // ================================
  Future<void> _fetchEkstrakulikuler() async {
    debugPrint("🚀 ===== MULAI FETCH EKSTRAKULIKULER =====");

    if (!mounted) return;

    setState(() {
      loadingEkskul = true;
    });

    try {
      if (authToken == null || authToken!.isEmpty) {
        debugPrint("❌ Token kosong, skip fetch ekskul");
        if (!mounted) return;
        setState(() {
          loadingEkskul = false;
        });
        return;
      }

      debugPrint("🔗 Mengakses: ${ApiConfig.baseUrl}/api/ekstrakulikuler");

      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/ekstrakulikuler"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
      );

      debugPrint("📡 Status Code: ${res.statusCode}");
      debugPrint("📦 Response Body: ${res.body}");

      if (!mounted) return;

      if (res.statusCode == 200) {
        try {
          final decoded = jsonDecode(res.body);
          debugPrint("✅ Decode JSON berhasil");
          debugPrint("📊 Tipe data: ${decoded.runtimeType}");

          // RESET DATA SEBELUMNYA
          final Map<int, int> newBiayaMap = {};
          final List<Map<String, dynamic>> newEkskulList = [];

          if (decoded is List) {
            debugPrint("📋 Jumlah data ekskul: ${decoded.length}");

            for (int i = 0; i < decoded.length; i++) {
              final item = decoded[i];
              debugPrint("\n--- Item Ekskul #$i ---");
              debugPrint("Item: $item");

              if (item is Map<String, dynamic>) {
                // AMBIL DATA DENGAN CARA YANG AMAN
                int id = 0;
                String nama = '';
                int biaya = 0;

                // 1. Cari ID
                if (item.containsKey('Ekstrakulikuler_Id')) {
                  id = _safeInt(item['Ekstrakulikuler_Id']);
                  debugPrint("ID dari 'Ekstrakulikuler_Id': $id");
                } else if (item.containsKey('id')) {
                  id = _safeInt(item['id']);
                  debugPrint("ID dari 'id': $id");
                }

                // 2. Cari Nama
                if (item.containsKey('nama')) {
                  nama = item['nama'].toString();
                  debugPrint("Nama dari 'nama': $nama");
                } else if (item.containsKey('name')) {
                  nama = item['name'].toString();
                  debugPrint("Nama dari 'name': $nama");
                }

                // 3. Cari Biaya
                if (item.containsKey('biaya')) {
                  biaya = _safeInt(item['biaya']);
                  debugPrint("Biaya dari 'biaya': $biaya");
                } else if (item.containsKey('Biaya')) {
                  biaya = _safeInt(item['Biaya']);
                  debugPrint("Biaya dari 'Biaya': $biaya");
                }

                // VALIDASI DATA
                if (id > 0) {
                  newBiayaMap[id] = biaya;
                  newEkskulList.add({
                    'Ekstrakulikuler_Id': id,
                    'nama': nama.isEmpty ? 'Ekskul $id' : nama,
                    'biaya': biaya,
                  });

                  debugPrint(
                    "✅ DITAMBAHKAN: ID=$id, Nama='$nama', Biaya=Rp $biaya",
                  );
                } else {
                  debugPrint("⚠️ DIABAIKAN: ID tidak valid ($id)");
                }
              } else {
                debugPrint("❌ Item bukan Map, tipe: ${item.runtimeType}");
              }
            }
          } else {
            debugPrint("❌ Response bukan List, tipe: ${decoded.runtimeType}");
            debugPrint("Response value: $decoded");
          }

          // TAMPILKAN HASIL AKHIR
          debugPrint("\n===== HASIL AKHIR =====");
          debugPrint("Total ekskul ditemukan: ${newEkskulList.length}");
          debugPrint("biayaEkskulMap size: ${newBiayaMap.length}");

          if (newBiayaMap.isNotEmpty) {
            debugPrint("Isi biayaEkskulMap:");
            newBiayaMap.forEach((key, value) {
              debugPrint("  ID $key: Rp $value");
            });
          } else {
            debugPrint("⚠️ biayaEkskulMap KOSONG!");
          }

          if (!mounted) return;

          setState(() {
            ekstrakulikulerList = newEkskulList;
            biayaEkskulMap = newBiayaMap;
            loadingEkskul = false;
          });

          debugPrint("✅ Data ekskul berhasil di-load ke state");
        } catch (e) {
          debugPrint("❌ ERROR decode JSON: $e");
          if (!mounted) return;
          setState(() {
            loadingEkskul = false;
          });
        }
      } else {
        debugPrint("❌ HTTP Error: ${res.statusCode}");
        debugPrint("Response error: ${res.body}");
        if (!mounted) return;
        setState(() {
          loadingEkskul = false;
        });
      }
    } catch (e) {
      debugPrint("❌ ERROR jaringan: $e");
      if (!mounted) return;
      setState(() {
        loadingEkskul = false;
      });
    }

    debugPrint("===== SELESAI FETCH EKSTRAKULIKULER =====\n");
  }

  // ================================
  // AMBIL DATA PEMBAYARAN - DIPERBAIKI
  // ================================
  Future<void> fetchPembayaran() async {
    debugPrint("🚀 ===== MULAI FETCH PEMBAYARAN =====");

    if (!mounted) return;

    setState(() {
      loading = true;
      errorMessage = '';
    });

    try {
      if (authToken == null || authToken!.isEmpty) {
        if (!mounted) return;
        setState(() {
          loading = false;
          errorMessage = 'Token tidak ditemukan. Silakan login kembali.';
        });
        return;
      }

      final res = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/admin/pembayaran"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
      );

      debugPrint("📡 Status: ${res.statusCode}");

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final List<Map<String, dynamic>> dataList = [];

        debugPrint(
          "📊 Data pembayaran diterima, jumlah: ${decoded is List ? decoded.length : 'N/A'}",
        );

        // DEBUG: Tampilkan map ekskul yang sudah di-load
        debugPrint("📋 biayaEkskulMap saat ini: $biayaEkskulMap");

        if (decoded is List) {
          for (var item in decoded) {
            if (item is Map<String, dynamic>) {
              final safeItem = Map<String, dynamic>.from(item);

              // Ambil data dasar
              final siswaId = _safeInt(safeItem['Siswa_Id']);
              final pembayaranId = _safeInt(safeItem['Pembayaran_Id']);
              final biayaSpp = _safeInt(safeItem['Biaya_SPP']);
              final biayaCatering = _safeInt(safeItem['Biaya_Catering']);
              final ekskulId = _safeInt(safeItem['Ekstrakulikuler_Id']);
              final totalBackend = _safeInt(safeItem['Total_Bayar']);

              debugPrint("\n--- Proses Pembayaran ID: $pembayaranId ---");
              debugPrint("Ekskul ID dari data: $ekskulId");

              // CARI BIAYA EKSTRAKULIKULER - DENGAN CARA YANG AMAN
              int biayaEkskul = 0;
              String namaEkskul = '';

              // Cara 1: Cari di map yang sudah di-load
              if (ekskulId > 0) {
                // Gunakan akses langsung ke map, bukan fungsi _getBiayaEkskul
                if (biayaEkskulMap.containsKey(ekskulId)) {
                  biayaEkskul = biayaEkskulMap[ekskulId]!;
                  debugPrint(
                    "✅ Biaya ekskul ditemukan di map: Rp $biayaEkskul",
                  );

                  // Cari nama ekskul dari list
                  for (var ekskul in ekstrakulikulerList) {
                    if (_safeInt(ekskul['Ekstrakulikuler_Id']) == ekskulId) {
                      namaEkskul =
                          ekskul['nama']?.toString() ?? 'Ekskul $ekskulId';
                      break;
                    }
                  }
                } else {
                  debugPrint(
                    "⚠️ Ekskul ID $ekskulId tidak ditemukan di biayaEkskulMap",
                  );
                  debugPrint("Keys yang ada: ${biayaEkskulMap.keys.toList()}");
                }
              } else {
                debugPrint("ℹ️ Tidak ada ekskul (ID: 0)");
              }

              // HITUNG TOTAL YANG SEHARUSNYA
              final totalSeharusnya = biayaSpp + biayaCatering + biayaEkskul;

              debugPrint("🧮 PERHITUNGAN:");
              debugPrint("  SPP: Rp $biayaSpp");
              debugPrint("  Catering: Rp $biayaCatering");
              debugPrint("  Ekskul: Rp $biayaEkskul");
              debugPrint("  Total seharusnya: Rp $totalSeharusnya");
              debugPrint("  Total dari backend: Rp $totalBackend");

              // SIMPAN DATA
              safeItem['nama_siswa'] = _getNamaSiswa(safeItem);
              safeItem['ekskul_nama'] = namaEkskul;
              safeItem['ekskul_biaya'] = biayaEkskul;

              // JIKA BACKEND SALAH, PERBAIKI
              if (totalBackend != totalSeharusnya) {
                debugPrint(
                  "⚠️ PERBAIKI: Backend salah! ${totalBackend} ≠ ${totalSeharusnya}",
                );
                safeItem['Total_Bayar'] = totalSeharusnya;
              } else {
                safeItem['Total_Bayar'] = totalBackend;
              }

              debugPrint("✅ Total akhir: Rp ${safeItem['Total_Bayar']}");

              dataList.add(safeItem);
            }
          }
        }

        // Sort
        dataList.sort((a, b) {
          final dateA = _parseDateTime(a['created_at']);
          final dateB = _parseDateTime(b['created_at']);
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });

        if (!mounted) return;

        setState(() {
          pembayaran = dataList;
          loading = false;
        });

        debugPrint("✅ Total data pembayaran: ${pembayaran.length}");
      } else if (res.statusCode == 401) {
        setState(() {
          loading = false;
          errorMessage = 'Session expired. Silakan login kembali.';
        });
      } else {
        setState(() {
          loading = false;
          errorMessage = 'Error ${res.statusCode}: Gagal memuat data';
        });
      }
    } catch (e) {
      debugPrint("❌ ERROR FETCH PEMBAYARAN: $e");

      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = 'Koneksi error: ${e.toString()}';
      });
    }

    debugPrint("===== SELESAI FETCH PEMBAYARAN =====\n");
  }

  // ================================
  // HELPER FUNCTIONS - DIPERBAIKI
  // ================================
  int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    if (value is double) return value.toInt();
    if (value is bool) return value ? 1 : 0;
    return 0;
  }

  DateTime? _parseDateTime(dynamic date) {
    if (date == null) return null;
    try {
      if (date is String) return DateTime.tryParse(date);
      return null;
    } catch (e) {
      return null;
    }
  }

  // FUNGSI INI DISEDERHANAKAN UNTUK MENGHINDARI ERROR
  String _getNamaEkskul(int ekskulId) {
    try {
      if (ekskulId <= 0) return '';

      // Akses langsung ke list, jangan gunakan tipe checking yang kompleks
      for (var ekskul in ekstrakulikulerList) {
        if (_safeInt(ekskul['Ekstrakulikuler_Id']) == ekskulId) {
          return ekskul['nama']?.toString() ?? 'Ekskul $ekskulId';
        }
      }
      return 'Ekskul $ekskulId';
    } catch (e) {
      debugPrint('Error _getNamaEkskul: $e');
      return 'Ekskul $ekskulId';
    }
  }

  // FUNGSI INI DIPERBAIKI DENGAN NULL SAFETY EKSTRA
  int _getBiayaEkskul(int ekskulId) {
    try {
      // Debug untuk melacak masalah
      debugPrint("Mencari biaya ekskul ID: $ekskulId");
      debugPrint("biayaEkskulMap is null: ${biayaEkskulMap == null}");
      debugPrint("biayaEkskulMap length: ${biayaEkskulMap.length}");

      if (ekskulId <= 0) {
        debugPrint("Ekskul ID tidak valid: $ekskulId");
        return 0;
      }

      // Pastikan map tidak null sebelum mengakses
      if (biayaEkskulMap.isEmpty) {
        debugPrint("⚠️ biayaEkskulMap KOSONG!");
        debugPrint("Available keys: ${biayaEkskulMap.keys.toList()}");
        return 0;
      }

      // Gunakan null-aware operator
      final biaya = biayaEkskulMap[ekskulId];
      debugPrint("Biaya ditemukan untuk ID $ekskulId: $biaya");

      return biaya ?? 0;
    } catch (e) {
      debugPrint("❌ ERROR _getBiayaEkskul: $e");
      debugPrint("Ekskul ID: $ekskulId");
      return 0; // Return 0 sebagai fallback
    }
  }

  // ================================
  // FUNGSI EDIT DATA - DIPERBAIKI
  // ================================
  Future<void> _editData(Map<String, dynamic> data) async {
    final siswaController = TextEditingController(
      text: data['Siswa_Id']?.toString() ?? '',
    );
    final bulanController = TextEditingController(
      text: data['Bulan']?.toString() ?? '',
    );
    final tahunController = TextEditingController(
      text: data['Tahun_Ajaran']?.toString() ?? '',
    );
    final sppController = TextEditingController(
      text: data['Biaya_SPP']?.toString() ?? '',
    );
    final cateringController = TextEditingController(
      text: data['Biaya_Catering']?.toString() ?? '',
    );

    final ekskulId = _safeInt(data['Ekstrakulikuler_Id']);
    int? selectedEkskulId = ekskulId > 0 ? ekskulId : null;
    // GUNAKAN AKSES LANGSUNG KE MAP, BUKAN FUNGSI _getBiayaEkskul
    int selectedEkskulBiaya = selectedEkskulId != null
        ? (biayaEkskulMap[selectedEkskulId] ?? 0)
        : 0;

    final pembayaranId = _safeInt(data['Pembayaran_Id']);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Edit Data Pembayaran",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF465940),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "ID: ${data['Pembayaran_Id'] ?? '-'}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 20),

                    // Form fields
                    _buildFormField(
                      controller: siswaController,
                      label: "ID Siswa",
                      hint: "Masukkan ID Siswa",
                      icon: Icons.person,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            controller: bulanController,
                            label: "Bulan",
                            hint: "Contoh: Januari",
                            icon: Icons.calendar_month,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFormField(
                            controller: tahunController,
                            label: "Tahun Ajaran",
                            hint: "Contoh: 2024",
                            icon: Icons.date_range,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    _buildFormField(
                      controller: sppController,
                      label: "Biaya SPP",
                      hint: "Masukkan nominal SPP",
                      icon: Icons.money,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 15),

                    _buildFormField(
                      controller: cateringController,
                      label: "Biaya Catering",
                      hint: "Masukkan nominal catering",
                      icon: Icons.restaurant,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 15),

                    // Dropdown ekstrakurikuler
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ekstrakulikuler (Opsional)",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              isExpanded: true,
                              value: selectedEkskulId,
                              hint: const Text("Pilih ekstrakurikuler"),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text("Tidak ada ekstrakurikuler"),
                                ),
                                ...ekstrakulikulerList.map((ekskul) {
                                  final id = _safeInt(
                                    ekskul['Ekstrakulikuler_Id'],
                                  );
                                  final nama =
                                      ekskul['nama']?.toString() ??
                                      "Ekskul $id";
                                  final biaya = _safeInt(ekskul['biaya']);
                                  return DropdownMenuItem<int?>(
                                    value: id,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(nama),
                                        Text(
                                          "Rp ${_formatRupiah(biaya)}",
                                          style: const TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedEkskulId = value;
                                  // GUNAKAN AKSES LANGSUNG KE MAP
                                  selectedEkskulBiaya = value != null
                                      ? (biayaEkskulMap[value] ?? 0)
                                      : 0;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Preview total
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: greenMain.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: greenMain.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("SPP:", style: TextStyle(color: greenMain)),
                              Text(
                                _formatRupiahString(sppController.text),
                                style: TextStyle(color: greenMain),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Catering:",
                                style: TextStyle(color: greenMain),
                              ),
                              Text(
                                _formatRupiahString(cateringController.text),
                                style: TextStyle(color: greenMain),
                              ),
                            ],
                          ),
                          if (selectedEkskulBiaya > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Ekstrakurikuler:",
                                  style: TextStyle(color: greenMain),
                                ),
                                Text(
                                  "Rp ${_formatRupiah(selectedEkskulBiaya)}",
                                  style: TextStyle(color: greenMain),
                                ),
                              ],
                            ),
                          ],
                          const Divider(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Baru:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: greenMain,
                                ),
                              ),
                              Text(
                                _hitungTotalPreview(
                                  sppController.text,
                                  cateringController.text,
                                  selectedEkskulBiaya,
                                ),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: greenMain,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Batal"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            if (pembayaranId == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('ID pembayaran tidak valid'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Validasi
                            if (siswaController.text.isEmpty ||
                                bulanController.text.isEmpty ||
                                tahunController.text.isEmpty ||
                                sppController.text.isEmpty ||
                                cateringController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Harap isi semua field wajib'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            try {
                              final Map<String, dynamic> requestBody = {
                                "Siswa_Id": int.parse(siswaController.text),
                                "Bulan": bulanController.text,
                                "Tahun_Ajaran": tahunController.text,
                                "Biaya_SPP": int.parse(sppController.text),
                                "Biaya_Catering": int.parse(
                                  cateringController.text,
                                ),
                              };

                              if (selectedEkskulId != null) {
                                requestBody["Ekstrakulikuler_Id"] =
                                    selectedEkskulId;
                              }

                              debugPrint(
                                "Edit Request Body: ${jsonEncode(requestBody)}",
                              );

                              final response = await http.put(
                                Uri.parse(
                                  "${ApiConfig.baseUrl}/api/admin/pembayaran/$pembayaranId",
                                ),
                                headers: {
                                  "Accept": "application/json",
                                  "Content-Type": "application/json",
                                  "Authorization": "Bearer $authToken",
                                },
                                body: jsonEncode(requestBody),
                              );

                              debugPrint(
                                "Edit Response Status: ${response.statusCode}",
                              );
                              debugPrint(
                                "Edit Response Body: ${response.body}",
                              );

                              if (response.statusCode == 200) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('✅ Data berhasil diperbarui'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                await fetchPembayaran();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '❌ Gagal mengupdate data: ${response.statusCode}',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('❌ Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenMain,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Update"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================================
  // FUNGSI KONFIRMASI HAPUS - DIPERBAIKI
  // ================================
  void _showDeleteConfirmation(Map<String, dynamic> item) {
    final id = _safeInt(item['Pembayaran_Id']);
    final namaSiswa = _getNamaSiswa(item);
    final total = rupiah(_safeInt(item['Total_Bayar']));
    final bulanTahun = _formatBulanTahun(item['Bulan'], item['Tahun_Ajaran']);
    final ekskulId = _safeInt(item['Ekstrakulikuler_Id']);
    // GUNAKAN DATA LANGSUNG DARI ITEM, JANGAN PANGGIL _getNamaEkskul LAGI
    final namaEkskul = ekskulId > 0 ? item['ekskul_nama']?.toString() : null;

    if (id == 0) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hapus data pembayaran untuk:"),
            const SizedBox(height: 8),
            Text(
              namaSiswa,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(bulanTahun, style: const TextStyle(fontSize: 14)),
            if (namaEkskul != null) ...[
              const SizedBox(height: 4),
              Text(
                "Ekstrakurikuler: $namaEkskul",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    total,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
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
            onPressed: () async {
              Navigator.pop(context);
              await hapus(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  // ================================
  // FUNGSI HAPUS DATA
  // ================================
  Future<void> hapus(int id) async {
    try {
      debugPrint("Menghapus pembayaran ID: $id");

      final response = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/api/admin/pembayaran/$id"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $authToken",
        },
      );

      debugPrint("Delete Response Status: ${response.statusCode}");
      debugPrint("Delete Response Body: ${response.body}");

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Data berhasil dihapus'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        await fetchPembayaran();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menghapus data: ${response.statusCode}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Delete Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // FORM TAMBAH DATA - DIPERBAIKI
  Future<void> _tambahData() async {
    final siswaController = TextEditingController();
    final bulanController = TextEditingController();
    final tahunController = TextEditingController();
    final sppController = TextEditingController();
    final cateringController = TextEditingController();

    bulanController.text = 'Januari';
    tahunController.text = DateTime.now().year.toString();

    int? selectedEkskulId;
    int selectedEkskulBiaya = 0;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tambah Data Pembayaran",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF465940),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildFormField(
                      controller: siswaController,
                      label: "ID Siswa",
                      hint: "Masukkan ID Siswa",
                      icon: Icons.person,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            controller: bulanController,
                            label: "Bulan",
                            hint: "Contoh: Januari",
                            icon: Icons.calendar_month,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildFormField(
                            controller: tahunController,
                            label: "Tahun Ajaran",
                            hint: "Contoh: 2024",
                            icon: Icons.date_range,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    _buildFormField(
                      controller: sppController,
                      label: "Biaya SPP",
                      hint: "Masukkan nominal SPP",
                      icon: Icons.money,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 15),

                    _buildFormField(
                      controller: cateringController,
                      label: "Biaya Catering",
                      hint: "Masukkan nominal catering",
                      icon: Icons.restaurant,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 15),

                    // Dropdown ekstrakurikuler
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ekstrakulikuler (Opsional)",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              isExpanded: true,
                              value: selectedEkskulId,
                              hint: const Text("Pilih ekstrakurikuler"),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text("Tidak ada ekstrakurikuler"),
                                ),
                                ...ekstrakulikulerList.map((ekskul) {
                                  final id = _safeInt(
                                    ekskul['Ekstrakulikuler_Id'],
                                  );
                                  final nama =
                                      ekskul['nama']?.toString() ??
                                      "Ekskul $id";
                                  final biaya = _safeInt(ekskul['biaya']);
                                  return DropdownMenuItem<int?>(
                                    value: id,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(nama),
                                        Text(
                                          "Rp ${_formatRupiah(biaya)}",
                                          style: const TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedEkskulId = value;
                                  // GUNAKAN AKSES LANGSUNG KE MAP
                                  selectedEkskulBiaya = value != null
                                      ? (biayaEkskulMap[value] ?? 0)
                                      : 0;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Preview total
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: greenMain.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("SPP:", style: TextStyle(color: greenMain)),
                              Text(
                                _formatRupiahString(sppController.text),
                                style: TextStyle(color: greenMain),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Catering:",
                                style: TextStyle(color: greenMain),
                              ),
                              Text(
                                _formatRupiahString(cateringController.text),
                                style: TextStyle(color: greenMain),
                              ),
                            ],
                          ),
                          if (selectedEkskulBiaya > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Ekstrakurikuler:",
                                  style: TextStyle(color: greenMain),
                                ),
                                Text(
                                  "Rp ${_formatRupiah(selectedEkskulBiaya)}",
                                  style: TextStyle(color: greenMain),
                                ),
                              ],
                            ),
                          ],
                          const Divider(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: greenMain,
                                ),
                              ),
                              Text(
                                _hitungTotalPreview(
                                  sppController.text,
                                  cateringController.text,
                                  selectedEkskulBiaya,
                                ),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: greenMain,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Batal"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            // Validasi
                            if (siswaController.text.isEmpty ||
                                bulanController.text.isEmpty ||
                                tahunController.text.isEmpty ||
                                sppController.text.isEmpty ||
                                cateringController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Harap isi semua field wajib'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            try {
                              final Map<String, dynamic> requestBody = {
                                "Siswa_Id": int.parse(siswaController.text),
                                "Bulan": bulanController.text,
                                "Tahun_Ajaran": tahunController.text,
                                "Biaya_SPP": int.parse(sppController.text),
                                "Biaya_Catering": int.parse(
                                  cateringController.text,
                                ),
                              };

                              if (selectedEkskulId != null) {
                                requestBody["Ekstrakulikuler_Id"] =
                                    selectedEkskulId;
                              }

                              debugPrint(
                                "Request Body: ${jsonEncode(requestBody)}",
                              );

                              final response = await http.post(
                                Uri.parse(
                                  "${ApiConfig.baseUrl}/api/admin/pembayaran",
                                ),
                                headers: {
                                  "Accept": "application/json",
                                  "Content-Type": "application/json",
                                  "Authorization": "Bearer $authToken",
                                },
                                body: jsonEncode(requestBody),
                              );

                              debugPrint(
                                "Response Status: ${response.statusCode}",
                              );
                              debugPrint("Response Body: ${response.body}");

                              if (response.statusCode == 200 ||
                                  response.statusCode == 201) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      '✅ Data berhasil ditambahkan',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                await fetchPembayaran();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '❌ Gagal menambah data: ${response.statusCode}',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('❌ Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenMain,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Simpan"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================================
  // WIDGET BUILDERS - DIPERBAIKI
  // ================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamBg,
      body: Row(
        children: [
          SidebarAdmin(onMenuSelected: (_) {}),
          Expanded(
            child: Column(
              children: [
                _buildAdminHeader(), // Header tanpa tombol keluar
                _buildSubHeader(),
                if (loadingEkskul) ...[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Memuat data ekstrakurikuler...",
                      style: TextStyle(color: greenMain),
                    ),
                  ),
                ],
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminHeader() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      color: greenMain,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 24,
            child: Icon(Icons.person, color: greenMain, size: 32),
          ),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, $adminName!",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                adminEmail,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          // TOMBOL KELUAR DIHAPUS DI SINI
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Data Pembayaran",
                style: TextStyle(
                  color: Color(0xFF465940),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Kelola data pembayaran siswa",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text("Tambah Data"),
            onPressed: _tambahData,
            style: ElevatedButton.styleFrom(
              backgroundColor: greenMain,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: greenMain),
            const SizedBox(height: 16),
            Text(
              "Memuat data pembayaran...",
              style: TextStyle(color: greenMain, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: fetchPembayaran,
                style: ElevatedButton.styleFrom(
                  backgroundColor: greenMain,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }

    if (pembayaran.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, color: greenMain, size: 80),
            const SizedBox(height: 16),
            Text(
              "Belum ada data pembayaran",
              style: TextStyle(
                color: greenMain,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _tambahData,
              icon: const Icon(Icons.add),
              label: const Text("Tambah Data Pertama"),
              style: ElevatedButton.styleFrom(
                backgroundColor: greenMain,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // GRAND TOTAL CARD DIHAPUS DI SINI
    // Langsung tampilkan tabel tanpa summary card

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          // Langsung tampilkan tabel tanpa grand total card
          _buildDataTable(),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: greenMain.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    "ID Siswa",
                    style: TextStyle(
                      color: Color(0xFF465940),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Nama Siswa",
                    style: TextStyle(
                      color: Color(0xFF465940),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Deskripsi",
                    style: TextStyle(
                      color: Color(0xFF465940),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Bulan/Tahun",
                    style: TextStyle(
                      color: Color(0xFF465940),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    "Jumlah",
                    style: TextStyle(
                      color: Color(0xFF465940),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    "Aksi",
                    style: TextStyle(
                      color: Color(0xFF465940),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Rows - DIPERBAIKI UNTUK MENGHINDARI PEMANGGILAN _getBiayaEkskul
          ...pembayaran.map((item) {
            final siswaId = _safeInt(item['Siswa_Id']);
            final ekskulId = _safeInt(item['Ekstrakulikuler_Id']);
            // GUNAKAN DATA LANGSUNG DARI ITEM, JANGAN PANGGIL _getBiayaEkskul
            final biayaEkskul = _safeInt(item['ekskul_biaya'] ?? 0);
            final total = _safeInt(item['Total_Bayar']);
            final biayaSpp = _safeInt(item['Biaya_SPP']);
            final biayaCatering = _safeInt(item['Biaya_Catering']);
            final namaEkskul = item['ekskul_nama']?.toString() ?? '';

            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        siswaId.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _getNamaSiswa(item),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _buildDeskripsi(
                        item,
                        ekskulId,
                        biayaEkskul,
                        namaEkskul,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatBulanTahun(item['Bulan'], item['Tahun_Ajaran']),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            rupiah(total),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          if (biayaEkskul > 0)
                            Text(
                              "(+${rupiah(biayaEkskul)})",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.blue,
                            ),
                            onPressed: () => _editData(item),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () => _showDeleteConfirmation(item),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDeskripsi(
    Map<String, dynamic> item,
    int ekskulId,
    int biayaEkskul,
    String namaEkskul,
  ) {
    try {
      final List<String> components = [];

      final biayaSpp = _safeInt(item['Biaya_SPP']);
      final biayaCatering = _safeInt(item['Biaya_Catering']);

      if (biayaSpp > 0) components.add("SPP");
      if (biayaCatering > 0) components.add("Catering");

      if (namaEkskul.isNotEmpty) {
        components.add(namaEkskul);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(components.join(" + "), style: const TextStyle(fontSize: 14)),
          if (biayaEkskul > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "📌 $namaEkskul: ${rupiah(biayaEkskul)}",
                style: TextStyle(
                  fontSize: 11,
                  color: greenMain,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => _showDetailDialog(item),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.remove_red_eye, size: 14, color: greenMain),
                const SizedBox(width: 4),
                Text(
                  "Lihat rincian",
                  style: TextStyle(
                    fontSize: 12,
                    color: greenMain,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } catch (e) {
      debugPrint('Error _buildDeskripsi: $e');
      return const Text('Deskripsi tidak tersedia');
    }
  }

  void _showDetailDialog(Map<String, dynamic> data) {
    final total = _safeInt(data['Total_Bayar']);
    final biayaSpp = _safeInt(data['Biaya_SPP']);
    final biayaCatering = _safeInt(data['Biaya_Catering']);
    final ekskulId = _safeInt(data['Ekstrakulikuler_Id']);
    // GUNAKAN DATA LANGSUNG DARI ITEM, JANGAN PANGGIL _getBiayaEkskul
    final biayaEkskul = _safeInt(data['ekskul_biaya'] ?? 0);
    final namaEkskul = data['ekskul_nama']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rincian Pembayaran",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: greenMain,
                  ),
                ),
                const SizedBox(height: 15),

                _detailRow(
                  "ID Pembayaran",
                  data['Pembayaran_Id']?.toString() ?? "-",
                ),
                _detailRow("Nama Siswa", _getNamaSiswa(data)),
                _detailRow(
                  "Bulan/Tahun",
                  _formatBulanTahun(data['Bulan'], data['Tahun_Ajaran']),
                ),

                const Divider(height: 20),
                Text(
                  "Komponen Biaya:",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: greenMain,
                  ),
                ),
                const SizedBox(height: 10),

                _detailRow("SPP", rupiah(biayaSpp)),
                _detailRow("Catering", rupiah(biayaCatering)),
                if (biayaEkskul > 0)
                  _detailRow(
                    namaEkskul.isNotEmpty ? namaEkskul : "Ekstrakurikuler",
                    rupiah(biayaEkskul),
                  ),

                const Divider(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: greenMain.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Bayar:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: greenMain,
                        ),
                      ),
                      Text(
                        rupiah(total),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: greenMain,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenMain,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Tutup"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================
  // HELPER WIDGETS & FUNCTIONS
  // ================================
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: keyboardType,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _getNamaSiswa(Map<String, dynamic> item) {
    try {
      // Prioritas: nama_siswa yang sudah di-extract di fetchPembayaran
      if (item.containsKey('nama_siswa') && item['nama_siswa'] != null) {
        return item['nama_siswa'].toString();
      }

      // Fallback ke siswa relasi
      if (item.containsKey('siswa') && item['siswa'] is Map<String, dynamic>) {
        final siswa = item['siswa'] as Map<String, dynamic>;
        return siswa['Nama']?.toString() ??
            'Siswa ${_safeInt(item['Siswa_Id'])}';
      }

      return 'Siswa ${_safeInt(item['Siswa_Id'])}';
    } catch (e) {
      debugPrint('Error _getNamaSiswa: $e');
      final siswaId = _safeInt(item['Siswa_Id']);
      return 'Siswa $siswaId';
    }
  }

  String _formatBulanTahun(dynamic bulan, dynamic tahun) {
    final bulanStr = bulan?.toString() ?? '-';
    final tahunStr = tahun?.toString() ?? '-';
    return '$bulanStr/$tahunStr';
  }

  String _hitungTotalPreview(String spp, String catering, int biayaEkskul) {
    try {
      int total = 0;
      if (spp.isNotEmpty) total += int.parse(spp);
      if (catering.isNotEmpty) total += int.parse(catering);
      total += biayaEkskul;
      return rupiah(total);
    } catch (e) {
      return "Rp 0";
    }
  }

  String _formatRupiahString(String value) {
    try {
      if (value.isEmpty) return "Rp 0";
      return rupiah(int.parse(value));
    } catch (e) {
      return "Rp 0";
    }
  }

  String rupiah(int value) {
    return "Rp ${_formatRupiah(value)}";
  }

  String _formatRupiah(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (match) => "${match[1]}.",
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
