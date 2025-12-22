import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/widgets/sidebarAdmin.dart';
import 'package:frontend/env/api_base_url.dart';
import 'data_guru.dart';
import 'data_kelas.dart';
import 'data_orangTua.dart';
import 'dashboard_admin.dart';
import 'jadwal_pelajaran.dart';
import 'informasi_pembayaran.dart';

class DataSiswaPage extends StatefulWidget {
  const DataSiswaPage({super.key});

  @override
  State<DataSiswaPage> createState() => _DataSiswaPageState();
}

class _DataSiswaPageState extends State<DataSiswaPage> {
  final Color primaryGreen = const Color(0xFF465940);
  final Color creamBg = const Color(0xFFFDFBF0);

  List<Map<String, dynamic>> dataSiswa = [];
  List<Map<String, dynamic>> dataOrangTua = [];
  List<Map<String, dynamic>> dataKelas = [];
  List<Map<String, dynamic>> dataEkstrakulikuler = [];

  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  String? authToken;
  String adminName = "Admin";
  String adminEmail = "admin@sekolah.com";

  String filterNama = "";
  String? filterKelas;
  String? filterJK;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _loadAdminData();
    await _loadToken();
    await fetchAllData();
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
      setState(() {
        authToken = token;
      });
    } catch (e) {}
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryGreen),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      controller.text = formattedDate;
    }
  }

  Future<void> fetchAllData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      if (authToken == null || authToken!.isEmpty) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Token tidak ditemukan. Silakan login kembali.';
        });
        return;
      }

      final siswaResponse = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/admin/siswa"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
      );

      if (siswaResponse.statusCode == 200) {
        final siswaDecoded = jsonDecode(siswaResponse.body);

        if (siswaDecoded['success'] == true) {
          List<Map<String, dynamic>> siswaList = [];

          for (var item in siswaDecoded['data']) {
            siswaList.add({
              'Siswa_Id': item['Siswa_Id']?.toString() ?? '0',
              'Nama': item['Nama']?.toString() ?? '',
              'Jenis_Kelamin': item['Jenis_Kelamin']?.toString() ?? 'L',
              'Tanggal_Lahir': item['Tanggal_Lahir']?.toString() ?? '',
              'Alamat': item['Alamat']?.toString() ?? '',
              'Agama': item['Agama']?.toString() ?? '',
              'Ekstrakulikuler_Id':
                  item['Ekstrakulikuler_Id']?.toString() ?? '0',
              'OrangTua_Id': item['OrangTua_Id']?.toString() ?? '0',
              'Kelas_Id': item['Kelas_Id']?.toString() ?? '0',
              'nama_ortu': item['nama_ortu']?.toString() ?? 'Orang Tua',
              'nama_kelas': item['nama_kelas']?.toString() ?? 'Kelas',
              'nama_ekskul': item['nama_ekskul']?.toString() ?? '',
            });
          }

          setState(() {
            dataSiswa = siswaList;
          });

          await _fetchOrangTua();
          await _fetchKelas();
          await _fetchEkstrakulikuler();

          setState(() {
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            hasError = true;
            errorMessage = siswaDecoded['message'] ?? 'Gagal memuat data siswa';
          });
        }
      } else if (siswaResponse.statusCode == 401) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = 'Sesi telah berakhir. Silakan login kembali.';
        });
      } else if (siswaResponse.statusCode == 500) {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage =
              'Error 500: Server mengalami masalah. Silakan coba lagi nanti.';
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage =
              'Error ${siswaResponse.statusCode}: Gagal memuat data siswa';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Koneksi error: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchOrangTua() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/admin/orangtua/list"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $authToken",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['success'] == true && decoded['data'] is List) {
          final dataList = decoded['data'] as List;
          final Map<String, Map<String, dynamic>> uniqueMap = {};

          for (var item in dataList) {
            final id = item['OrangTua_Id']?.toString();
            if (id != null && !uniqueMap.containsKey(id)) {
              uniqueMap[id] = item;
            }
          }

          setState(() {
            dataOrangTua = uniqueMap.values.toList();
          });
        }
      }
    } catch (e) {}
  }

  Future<void> _fetchKelas() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/admin/kelas/list"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $authToken",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['success'] == true && decoded['data'] is List) {
          final dataList = decoded['data'] as List;
          final Map<String, Map<String, dynamic>> uniqueMap = {};

          for (var item in dataList) {
            final id = item['Kelas_Id']?.toString();
            if (id != null && !uniqueMap.containsKey(id)) {
              uniqueMap[id] = item;
            }
          }

          setState(() {
            dataKelas = uniqueMap.values.toList();
          });
        }
      }
    } catch (e) {}
  }

  Future<void> _fetchEkstrakulikuler() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/api/ekstrakulikuler"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $authToken",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<dynamic> dataList = [];

        if (decoded is List) {
          dataList = decoded;
        } else if (decoded['success'] == true && decoded['data'] is List) {
          dataList = decoded['data'];
        }

        final Map<String, Map<String, dynamic>> uniqueMap = {};

        for (var item in dataList) {
          if (item is Map<String, dynamic>) {
            final id =
                item['Ekstrakulikuler_Id']?.toString() ??
                item['id']?.toString();
            if (id != null && id != '0' && !uniqueMap.containsKey(id)) {
              uniqueMap[id] = {
                'Ekstrakulikuler_Id': id,
                'nama': item['nama']?.toString() ?? '',
                'biaya': item['biaya']?.toString() ?? '0',
              };
            }
          }
        }

        setState(() {
          dataEkstrakulikuler = uniqueMap.values.toList();
        });
      }
    } catch (e) {}
  }

  Future<bool> tambahSiswa(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/admin/siswa"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          await fetchAllData();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> editSiswa(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/api/admin/siswa/$id"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          await fetchAllData();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> hapusSiswa(String id) async {
    try {
      final response = await http
          .delete(
            Uri.parse("${ApiConfig.baseUrl}/api/admin/siswa/$id"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $authToken",
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['success'] == true) {
          await fetchAllData();
          return true;
        } else {
          if (mounted && decoded['message']?.contains('pembayaran') == true ||
              decoded['message']?.contains('perizinan') == true) {
            _showForceDeleteOption(
              id,
              decoded['message'] ?? 'Data memiliki relasi terkait',
            );
          }
          return false;
        }
      } else if (response.statusCode == 400) {
        final decoded = jsonDecode(response.body);
        final errorMessage =
            decoded['message'] ?? 'Data siswa memiliki data terkait';

        if (mounted) {
          _showForceDeleteOption(id, errorMessage);
        }
        return false;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void _showForceDeleteOption(String id, String errorMessage) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tidak Dapat Menghapus"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange, size: 50),
            const SizedBox(height: 10),
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 15),
            const Text(
              "Apakah Anda ingin menghapus data siswa beserta semua data terkait?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _forceDeleteSiswa(id);
            },
            child: const Text("Hapus Semua"),
          ),
        ],
      ),
    );
  }

  Future<void> _forceDeleteSiswa(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("${ApiConfig.baseUrl}/api/admin/siswa/$id/force"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          await fetchAllData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Data siswa dan semua data terkait berhasil dihapus',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {}
  }

  List<Map<String, dynamic>> get filteredList {
    return dataSiswa.where((s) {
      final matchesNama =
          filterNama.isEmpty ||
          (s["Nama"]?.toString() ?? '').toLowerCase().contains(
            filterNama.toLowerCase(),
          );
      final matchesKelas =
          filterKelas == null ||
          (s["nama_kelas"]?.toString() ?? '') == filterKelas;
      final matchesJK = filterJK == null || s["Jenis_Kelamin"] == filterJK;
      return matchesNama && matchesKelas && matchesJK;
    }).toList();
  }

  String formatTanggal(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '-';

    try {
      if (tanggal.contains('T')) {
        final datePart = tanggal.split('T')[0];
        final parts = datePart.split('-');
        if (parts.length >= 3) {
          final year = parts[0];
          final month = parts[1];
          final day = parts[2];
          return '$day/$month/$year';
        }
      }

      if (tanggal.contains('-')) {
        final parts = tanggal.split('-');
        if (parts.length >= 3) {
          final year = parts[0];
          final month = parts[1];
          final day = parts[2];
          return '$day/$month/$year';
        }
      }

      return tanggal;
    } catch (e) {
      return tanggal;
    }
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
      case "Informasi Pembayaran":
        page = const DataPembayaranPage();
        break;
    }

    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }

  void showAddSiswaDialog() {
    if (_hasDuplicateIds(dataOrangTua, 'OrangTua_Id')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Terdapat duplikat ID Orang Tua. Harap perbaiki data terlebih dahulu.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_hasDuplicateIds(dataKelas, 'Kelas_Id')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Terdapat duplikat ID Kelas. Harap perbaiki data terlebih dahulu.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_hasDuplicateIds(dataEkstrakulikuler, 'Ekstrakulikuler_Id')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Terdapat duplikat ID Ekstrakulikuler. Harap perbaiki data terlebih dahulu.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final TextEditingController nama = TextEditingController();
    final TextEditingController jenisKelamin = TextEditingController(text: 'L');
    final TextEditingController tanggalLahir = TextEditingController();
    final TextEditingController alamat = TextEditingController();
    final TextEditingController agama = TextEditingController();

    String? selectedOrangTuaId;
    String? selectedKelasId;
    String? selectedEkskulId;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Tambahkan Data Siswa"),
            content: SizedBox(
              width: 450,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _inputField("Nama Siswa *", nama),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Jenis Kelamin *",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: const Text("Laki-laki"),
                                leading: Radio<String>(
                                  value: 'L',
                                  groupValue: jenisKelamin.text,
                                  onChanged: (value) {
                                    setStateDialog(() {
                                      jenisKelamin.text = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: const Text("Perempuan"),
                                leading: Radio<String>(
                                  value: 'P',
                                  groupValue: jenisKelamin.text,
                                  onChanged: (value) {
                                    setStateDialog(() {
                                      jenisKelamin.text = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _dateInputField("Tanggal Lahir *", tanggalLahir),
                    _inputField("Alamat *", alamat),
                    _inputField("Agama *", agama),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Orang Tua *",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              isExpanded: true,
                              value: selectedOrangTuaId?.isEmpty == true
                                  ? null
                                  : selectedOrangTuaId,
                              hint: dataOrangTua.isEmpty
                                  ? const Text("Belum ada data orang tua")
                                  : const Text("Pilih Orang Tua"),
                              items: dataOrangTua.isEmpty
                                  ? [
                                      const DropdownMenuItem<String?>(
                                        value: null,
                                        child: Text("Tidak ada data orang tua"),
                                      ),
                                    ]
                                  : [
                                      const DropdownMenuItem<String?>(
                                        value: null,
                                        child: Text("Pilih Orang Tua"),
                                      ),
                                      ...dataOrangTua
                                          .map((ortu) {
                                            final id =
                                                ortu['OrangTua_Id']
                                                    ?.toString() ??
                                                '';
                                            final namaOrtu =
                                                ortu['Nama']?.toString() ?? '';
                                            final emailOrtu =
                                                ortu['Email']?.toString() ?? '';

                                            if (id.isEmpty) return null;

                                            return DropdownMenuItem<String?>(
                                              value: id,
                                              child: Text(
                                                "$namaOrtu ($emailOrtu)",
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          })
                                          .where((item) => item != null)
                                          .cast<DropdownMenuItem<String?>>()
                                          .toList(),
                                    ],
                              onChanged: dataOrangTua.isEmpty
                                  ? null
                                  : (value) {
                                      setStateDialog(() {
                                        selectedOrangTuaId = value ?? '';
                                      });
                                    },
                            ),
                          ),
                        ),
                        if (dataOrangTua.isEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            "⚠️ Belum ada data orang tua. Silakan tambah data orang tua terlebih dahulu.",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Kelas *", style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              isExpanded: true,
                              value: selectedKelasId?.isEmpty == true
                                  ? null
                                  : selectedKelasId,
                              hint: const Text("Pilih Kelas"),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text("Pilih Kelas"),
                                ),
                                ...dataKelas
                                    .map((kelas) {
                                      final id =
                                          kelas['Kelas_Id']?.toString() ?? '';
                                      final namaKelas =
                                          kelas['Nama_Kelas']?.toString() ?? '';

                                      if (id.isEmpty) return null;

                                      return DropdownMenuItem<String?>(
                                        value: id,
                                        child: Text(
                                          namaKelas,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    })
                                    .where((item) => item != null)
                                    .cast<DropdownMenuItem<String?>>()
                                    .toList(),
                              ],
                              onChanged: (value) {
                                setStateDialog(() {
                                  selectedKelasId = value ?? '';
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Ekstrakulikuler (Opsional)",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              isExpanded: true,
                              value: selectedEkskulId == '0'
                                  ? null
                                  : selectedEkskulId,
                              hint: const Text("Pilih Ekstrakulikuler"),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text("Tidak ada"),
                                ),
                                ...dataEkstrakulikuler
                                    .map((ekskul) {
                                      final id =
                                          ekskul['Ekstrakulikuler_Id']
                                              ?.toString() ??
                                          '';
                                      final namaEkskul =
                                          ekskul['nama']?.toString() ?? '';

                                      if (id.isEmpty || id == '0') return null;

                                      return DropdownMenuItem<String?>(
                                        value: id,
                                        child: Text(
                                          namaEkskul,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    })
                                    .where((item) => item != null)
                                    .cast<DropdownMenuItem<String?>>()
                                    .toList(),
                              ],
                              onChanged: (value) {
                                setStateDialog(() {
                                  selectedEkskulId = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
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
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (nama.text.isEmpty ||
                      tanggalLahir.text.isEmpty ||
                      alamat.text.isEmpty ||
                      agama.text.isEmpty ||
                      selectedOrangTuaId == null ||
                      selectedKelasId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Harap isi semua field yang wajib (*)'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final data = {
                    "Nama": nama.text,
                    "Jenis_Kelamin": jenisKelamin.text,
                    "Tanggal_Lahir": tanggalLahir.text.trim(),
                    "Alamat": alamat.text,
                    "Agama": agama.text,
                    "OrangTua_Id": int.parse(selectedOrangTuaId!),
                    "Kelas_Id": int.parse(selectedKelasId!),
                    "Ekstrakulikuler_Id":
                        selectedEkskulId != null && selectedEkskulId!.isNotEmpty
                        ? int.parse(selectedEkskulId!)
                        : null,
                  };

                  final success = await tambahSiswa(data);
                  Navigator.pop(context);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Data siswa berhasil ditambahkan'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Gagal menambahkan data siswa'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _hasDuplicateIds(List<Map<String, dynamic>> list, String idKey) {
    final Set<String> ids = {};
    for (var item in list) {
      final id = item[idKey]?.toString() ?? '';
      if (id.isNotEmpty && ids.contains(id)) {
        return true;
      }
      ids.add(id);
    }
    return false;
  }

  void showEditSiswaDialog(int dataIndexInFiltered) {
    final siswa = filteredList[dataIndexInFiltered];
    final id = siswa['Siswa_Id'] as String;

    final TextEditingController nama = TextEditingController(
      text: siswa["Nama"]?.toString() ?? '',
    );
    final TextEditingController jenisKelamin = TextEditingController(
      text: siswa["Jenis_Kelamin"]?.toString() ?? 'L',
    );

    String tanggalAwal = siswa["Tanggal_Lahir"]?.toString() ?? '';
    String formattedTanggalAwal = tanggalAwal;

    if (tanggalAwal.contains('T')) {
      formattedTanggalAwal = tanggalAwal.split('T')[0];
    }

    final TextEditingController tanggalLahir = TextEditingController(
      text: formattedTanggalAwal,
    );
    final TextEditingController alamat = TextEditingController(
      text: siswa["Alamat"]?.toString() ?? '',
    );
    final TextEditingController agama = TextEditingController(
      text: siswa["Agama"]?.toString() ?? '',
    );

    String? selectedOrangTuaId = siswa["OrangTua_Id"]?.toString() ?? "";
    String? selectedKelasId = siswa["Kelas_Id"]?.toString() ?? "";
    String? selectedEkskulId = siswa["Ekstrakulikuler_Id"]?.toString() ?? "";

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Edit Data Siswa"),
            content: SizedBox(
              width: 450,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _inputField("Nama Siswa *", nama),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Jenis Kelamin *",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: const Text("Laki-laki"),
                                leading: Radio<String>(
                                  value: 'L',
                                  groupValue: jenisKelamin.text,
                                  onChanged: (value) {
                                    setStateDialog(() {
                                      jenisKelamin.text = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: const Text("Perempuan"),
                                leading: Radio<String>(
                                  value: 'P',
                                  groupValue: jenisKelamin.text,
                                  onChanged: (value) {
                                    setStateDialog(() {
                                      jenisKelamin.text = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _dateInputField("Tanggal Lahir *", tanggalLahir),
                    _inputField("Alamat *", alamat),
                    _inputField("Agama *", agama),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Orang Tua *",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              isExpanded: true,
                              value: selectedOrangTuaId?.isEmpty == true
                                  ? null
                                  : selectedOrangTuaId,
                              hint: const Text("Pilih Orang Tua"),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text("Pilih Orang Tua"),
                                ),
                                ...dataOrangTua
                                    .map((ortu) {
                                      final id =
                                          ortu['OrangTua_Id']?.toString() ?? '';
                                      final namaOrtu =
                                          ortu['Nama']?.toString() ?? '';
                                      final emailOrtu =
                                          ortu['Email']?.toString() ?? '';

                                      if (id.isEmpty) return null;

                                      return DropdownMenuItem<String?>(
                                        value: id,
                                        child: Text(
                                          "$namaOrtu ($emailOrtu)",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    })
                                    .where((item) => item != null)
                                    .cast<DropdownMenuItem<String?>>()
                                    .toList(),
                              ],
                              onChanged: (value) {
                                setStateDialog(() {
                                  selectedOrangTuaId = value ?? '';
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Kelas *", style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              isExpanded: true,
                              value: selectedKelasId?.isEmpty == true
                                  ? null
                                  : selectedKelasId,
                              hint: const Text("Pilih Kelas"),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text("Pilih Kelas"),
                                ),
                                ...dataKelas
                                    .map((kelas) {
                                      final id =
                                          kelas['Kelas_Id']?.toString() ?? '';
                                      final namaKelas =
                                          kelas['Nama_Kelas']?.toString() ?? '';

                                      if (id.isEmpty) return null;

                                      return DropdownMenuItem<String?>(
                                        value: id,
                                        child: Text(
                                          namaKelas,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    })
                                    .where((item) => item != null)
                                    .cast<DropdownMenuItem<String?>>()
                                    .toList(),
                              ],
                              onChanged: (value) {
                                setStateDialog(() {
                                  selectedKelasId = value ?? '';
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Ekstrakulikuler (Opsional)",
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              isExpanded: true,
                              value: selectedEkskulId == '0'
                                  ? null
                                  : selectedEkskulId,
                              hint: const Text("Pilih Ekstrakulikuler"),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text("Tidak ada"),
                                ),
                                ...dataEkstrakulikuler
                                    .map((ekskul) {
                                      final id =
                                          ekskul['Ekstrakulikuler_Id']
                                              ?.toString() ??
                                          '';
                                      final namaEkskul =
                                          ekskul['nama']?.toString() ?? '';

                                      if (id.isEmpty || id == '0') return null;

                                      return DropdownMenuItem<String?>(
                                        value: id,
                                        child: Text(
                                          namaEkskul,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    })
                                    .where((item) => item != null)
                                    .cast<DropdownMenuItem<String?>>()
                                    .toList(),
                              ],
                              onChanged: (value) {
                                setStateDialog(() {
                                  selectedEkskulId = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
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
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (nama.text.isEmpty ||
                      tanggalLahir.text.isEmpty ||
                      alamat.text.isEmpty ||
                      agama.text.isEmpty ||
                      selectedOrangTuaId == null ||
                      selectedKelasId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Harap isi semua field yang wajib (*)'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final data = {
                    "Nama": nama.text,
                    "Jenis_Kelamin": jenisKelamin.text,
                    "Tanggal_Lahir": tanggalLahir.text.trim(),
                    "Alamat": alamat.text,
                    "Agama": agama.text,
                    "OrangTua_Id": int.parse(selectedOrangTuaId!),
                    "Kelas_Id": int.parse(selectedKelasId!),
                    if (selectedEkskulId != null &&
                        selectedEkskulId!.isNotEmpty)
                      "Ekstrakulikuler_Id": int.parse(selectedEkskulId!),
                  };

                  final success = await editSiswa(id, data);
                  Navigator.pop(context);

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Data siswa berhasil diperbarui'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Gagal memperbarui data siswa'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      ),
    );
  }

  void showDeleteSiswaDialog(int dataIndexInFiltered) async {
    final siswa = filteredList[dataIndexInFiltered];
    final id = siswa['Siswa_Id'] as String;
    final nama = siswa["Nama"]?.toString() ?? 'Siswa';

    bool isDeleting = false;
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Hapus Data Siswa"),
            content: errorMessage != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 50),
                      const SizedBox(height: 10),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Apakah anda yakin ingin menghapus data siswa $nama?',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Text("Apakah anda yakin ingin menghapus data siswa $nama?"),
            actions: [
              if (isDeleting)
                const Center(child: CircularProgressIndicator())
              else ...[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    setStateDialog(() {
                      isDeleting = true;
                      errorMessage = null;
                    });

                    final success = await hapusSiswa(id);

                    if (!mounted) return;
                    Navigator.pop(context);

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '✅ Data siswa "$nama" berhasil dihapus',
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            '❌ Gagal menghapus data siswa. Periksa console untuk detail error.',
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 5),
                          action: SnackBarAction(
                            label: 'Coba Lagi',
                            onPressed: () {
                              showDeleteSiswaDialog(dataIndexInFiltered);
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text("Ya, Hapus"),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void showFilterDialog() {
    final TextEditingController namaCtrl = TextEditingController(
      text: filterNama,
    );
    String? kelasTmp = filterKelas;
    String? jkTmp = filterJK;

    final kelasOptions = <String>{
      for (var s in dataSiswa)
        if (s["nama_kelas"] != null) s["nama_kelas"]!.toString(),
    }.toList()..sort();

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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      value: kelasTmp,
                      decoration: InputDecoration(
                        labelText: "Kelas",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
            ),
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sidebarWidth = 250;
    final double availableWidth = screenWidth - sidebarWidth - 24;

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
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: showFilterDialog,
                              icon: const Icon(
                                Icons.filter_list,
                                color: Colors.black87,
                              ),
                              label: const Text(
                                "Filter",
                                style: TextStyle(color: Colors.black87),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                side: BorderSide(
                                  color: Colors.black.withOpacity(0.15),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: showAddSiswaDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text("+ Tambah Data"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Data Siswa",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF465940),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (isLoading)
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: primaryGreen,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Memuat data siswa...",
                                    style: TextStyle(
                                      color: primaryGreen,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (hasError)
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 50,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      errorMessage,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: fetchAllData,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryGreen,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 10,
                                        ),
                                      ),
                                      child: const Text("Coba Lagi"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else if (dataSiswa.isEmpty)
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    color: primaryGreen,
                                    size: 60,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Belum ada data siswa",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: showAddSiswaDialog,
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text("Tambah Data Pertama"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryGreen,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (filterNama.isNotEmpty ||
                                    filterKelas != null ||
                                    filterJK != null)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: creamBg,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: primaryGreen.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.filter_alt,
                                          color: primaryGreen,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            "Filter: " +
                                                [
                                                  if (filterNama.isNotEmpty)
                                                    "Nama '$filterNama'",
                                                  if (filterKelas != null)
                                                    "Kelas $filterKelas",
                                                  if (filterJK != null)
                                                    "JK ${filterJK == 'L' ? 'Laki-laki' : 'Perempuan'}",
                                                ].join(", "),
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 11,
                                            ),
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
                                          child: Text(
                                            "Hapus",
                                            style: TextStyle(
                                              color: primaryGreen,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Container(
                                  width: availableWidth,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      topRight: Radius.circular(8),
                                    ),
                                    border: Border.all(
                                      color: Colors.black12,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total: ${filteredList.length} siswa",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: primaryGreen,
                                          fontSize: 13,
                                        ),
                                      ),
                                      TextButton.icon(
                                        onPressed: fetchAllData,
                                        icon: Icon(
                                          Icons.refresh,
                                          size: 14,
                                          color: primaryGreen,
                                        ),
                                        label: Text(
                                          "Refresh",
                                          style: TextStyle(
                                            color: primaryGreen,
                                            fontSize: 11,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          minimumSize: Size.zero,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: availableWidth,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                      border: Border.all(
                                        color: Colors.black12,
                                        width: 1,
                                      ),
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: availableWidth,
                                        ),
                                        child: DataTable(
                                          columnSpacing: 8,
                                          headingRowHeight: 40,
                                          dataRowHeight: 50,
                                          horizontalMargin: 8,
                                          headingRowColor:
                                              MaterialStateProperty.all(
                                                primaryGreen.withOpacity(0.08),
                                              ),
                                          headingTextStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: primaryGreen,
                                            fontSize: 11,
                                          ),
                                          dataTextStyle: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 10,
                                          ),
                                          columns: const [
                                            DataColumn(
                                              label: SizedBox(
                                                width: 100,
                                                child: Text("Nama"),
                                              ),
                                            ),
                                            DataColumn(
                                              label: SizedBox(
                                                width: 100,
                                                child: Text("Orang Tua"),
                                              ),
                                            ),
                                            DataColumn(
                                              label: SizedBox(
                                                width: 60,
                                                child: Text("Agama"),
                                              ),
                                            ),
                                            DataColumn(
                                              label: SizedBox(
                                                width: 80,
                                                child: Text("Tgl Lahir"),
                                              ),
                                            ),
                                            DataColumn(
                                              label: SizedBox(
                                                width: 70,
                                                child: Text("Kelas"),
                                              ),
                                            ),
                                            DataColumn(
                                              label: SizedBox(
                                                width: 60,
                                                child: Text("Jenis Kelamin"),
                                              ),
                                            ),
                                            DataColumn(
                                              label: SizedBox(
                                                width: 100,
                                                child: Text("Ekstrakurikuler"),
                                              ),
                                            ),
                                            DataColumn(
                                              label: SizedBox(
                                                width: 150,
                                                child: Text("Alamat"),
                                              ),
                                            ),
                                            DataColumn(
                                              label: SizedBox(
                                                width: 60,
                                                child: Text(
                                                  "Aksi",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                          rows: List.generate(filteredList.length, (
                                            index,
                                          ) {
                                            final s = filteredList[index];
                                            return DataRow(
                                              cells: [
                                                DataCell(
                                                  SizedBox(
                                                    width: 100,
                                                    child: Text(
                                                      s["Nama"]?.toString() ??
                                                          '',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 100,
                                                    child: Text(
                                                      s["nama_ortu"]
                                                              ?.toString() ??
                                                          '',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 60,
                                                    child: Text(
                                                      s["Agama"]?.toString() ??
                                                          '',
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 80,
                                                    child: Text(
                                                      formatTanggal(
                                                        s["Tanggal_Lahir"]
                                                            ?.toString(),
                                                      ),
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 70,
                                                    child: Text(
                                                      s["nama_kelas"]
                                                              ?.toString() ??
                                                          '',
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 60,
                                                    child: Text(
                                                      s["Jenis_Kelamin"]
                                                                  ?.toString() ==
                                                              "L"
                                                          ? "Laki-laki"
                                                          : "Perempuan",
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 100,
                                                    child: Text(
                                                      s["nama_ekskul"]
                                                              ?.toString() ??
                                                          '-',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 150,
                                                    child: Text(
                                                      s["Alamat"]?.toString() ??
                                                          '',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  SizedBox(
                                                    width: 60,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          width: 24,
                                                          height: 24,
                                                          margin:
                                                              const EdgeInsets.only(
                                                                right: 2,
                                                              ),
                                                          child: IconButton(
                                                            tooltip: "Edit",
                                                            onPressed: () =>
                                                                showEditSiswaDialog(
                                                                  index,
                                                                ),
                                                            icon: Icon(
                                                              Icons.edit,
                                                              color:
                                                                  primaryGreen,
                                                              size: 12,
                                                            ),
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                const BoxConstraints(),
                                                            style: IconButton.styleFrom(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              minimumSize:
                                                                  Size.zero,
                                                              tapTargetSize:
                                                                  MaterialTapTargetSize
                                                                      .shrinkWrap,
                                                              visualDensity:
                                                                  VisualDensity
                                                                      .compact,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 24,
                                                          height: 24,
                                                          child: IconButton(
                                                            tooltip: "Hapus",
                                                            onPressed: () =>
                                                                showDeleteSiswaDialog(
                                                                  index,
                                                                ),
                                                            icon: Icon(
                                                              Icons.delete,
                                                              color: Colors
                                                                  .red
                                                                  .shade700,
                                                              size: 12,
                                                            ),
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                const BoxConstraints(),
                                                            style: IconButton.styleFrom(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              minimumSize:
                                                                  Size.zero,
                                                              tapTargetSize:
                                                                  MaterialTapTargetSize
                                                                      .shrinkWrap,
                                                              visualDensity:
                                                                  VisualDensity
                                                                      .compact,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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

  Widget _buildHeader() {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: primaryGreen,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20,
            child: Icon(Icons.person, color: Color(0xFF465940), size: 26),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, $adminName",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                adminEmail,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
        ),
      ),
    );
  }

  Widget _dateInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today, size: 18),
            onPressed: () => _selectDate(context, controller),
          ),
        ),
        onTap: () => _selectDate(context, controller),
      ),
    );
  }
}
