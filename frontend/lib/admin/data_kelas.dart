import 'package:flutter/material.dart';
import 'package:frontend/widgets/sidebarAdmin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/env/api_base_url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  String kelasDipilih = "Semua";

  List<dynamic> dataKelas = [];
  List<dynamic> dataGuru = [];
  bool isLoading = true;
  String? authToken;
  String adminName = "";
  String adminEmail = "";
  bool _formAlreadyShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (args != null && args['showAddForm'] == true && !_formAlreadyShown) {
      _formAlreadyShown = true;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _showTambahKelas();
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _formAlreadyShown = false;
    super.dispose();
  }

  final Set<int> _hovering = {};

  @override
  void initState() {
    super.initState();
    _loadTokenAndData();
  }

  Future<void> _loadTokenAndData() async {
    await _getAuthToken();
    await fetchKelas();
    await fetchGuru();
    await _loadAdminData();
  }

  // ===================== LOAD ADMIN DATA =====================
  Future<void> _loadAdminData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      adminName = prefs.getString('nama') ?? "Admin";
      adminEmail = prefs.getString('email') ?? "admin@sekolah.com";
    });
  }

  Future<void> _getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? prefs.getString('token');
      setState(() {
        authToken = token;
      });
    } catch (e) {
      print('Error getting token: $e');
    }
  }

  // ==========================================================
  //                 AMBIL DATA DARI BACKEND
  // ==========================================================
  Future<void> fetchKelas() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/kelas/list'),
        headers: {
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            dataKelas = responseData['data'] ?? [];
            isLoading = false;
          });
        } else {
          print('API Error: ${responseData['message']}');
          setState(() => isLoading = false);
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Network Error: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchGuru() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/guru/list'),
        headers: {
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            dataGuru = responseData['data'] ?? [];
          });
        }
      }
    } catch (e) {
      print('Error fetching guru: $e');
    }
  }

  // ==========================================================
  //                       FILTERING
  // ==========================================================
  List<dynamic> get filteredData {
    if (kelasDipilih == "Semua") {
      return dataKelas.where((item) {
        return item["Tahun_Ajar"] == tahunAjaran;
      }).toList();
    } else {
      return dataKelas.where((item) {
        return item["Tahun_Ajar"] == tahunAjaran &&
            item["Nama_Kelas"] == kelasDipilih;
      }).toList();
    }
  }

  // ==========================================================
  //                        TAMBAH KELAS
  // ==========================================================
  void _showTambahKelas() {
    TextEditingController namaKelasController = TextEditingController();
    TextEditingController tahunAjarController =
        TextEditingController(text: tahunAjaran);

    int? selectedGuruUtamaId;
    int? selectedGuruPendampingId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text("Tambah Kelas"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Input Nama Kelas
                    TextField(
                      controller: namaKelasController,
                      decoration: const InputDecoration(
                        labelText: "Nama Kelas",
                        hintText: "Contoh: Kelas 1A, Kelas 2B",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Tahun Ajar
                    TextField(
                      controller: tahunAjarController,
                      decoration: const InputDecoration(
                        labelText: "Tahun Ajar",
                        hintText: "Contoh: 2024/2025",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Guru Utama
                    const Text(
                      "Guru Utama:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<int>(
                        value: selectedGuruUtamaId,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text("Pilih Guru Utama"),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text("Pilih Guru Utama"),
                          ),
                          ...dataGuru.map((guru) {
                            return DropdownMenuItem<int>(
                              value: guru['Guru_Id'],
                              child: Text(guru['Nama'] ?? 'Unknown'),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedGuruUtamaId = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dropdown Guru Pendamping
                    const Text(
                      "Guru Pendamping:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<int>(
                        value: selectedGuruPendampingId,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text("Pilih Guru Pendamping (Opsional)"),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text("Tidak ada"),
                          ),
                          ...dataGuru.map((guru) {
                            return DropdownMenuItem<int>(
                              value: guru['Guru_Id'],
                              child: Text(guru['Nama'] ?? 'Unknown'),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedGuruPendampingId = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (namaKelasController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Nama kelas harus diisi"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (selectedGuruUtamaId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Guru utama harus dipilih"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final Map<String, dynamic> requestData = {
                      'Nama_Kelas': namaKelasController.text,
                      'Tahun_Ajar': tahunAjarController.text,
                      'Guru_Utama_Id': selectedGuruUtamaId,
                      'Guru_Pendamping_Id': selectedGuruPendampingId,
                    };

                    try {
                      final response = await http.post(
                        Uri.parse('${ApiConfig.baseUrl}/api/admin/kelas/create'),
                        headers: {
                          'Content-Type': 'application/json',
                          'Accept': 'application/json',
                          if (authToken != null)
                            'Authorization': 'Bearer $authToken',
                        },
                        body: jsonEncode(requestData),
                      );

                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        final Map<String, dynamic> responseData =
                            jsonDecode(response.body);
                        if (responseData['success'] == true) {
                          Navigator.pop(context);
                          await fetchKelas();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(responseData['message'] ??
                                  'Kelas berhasil ditambahkan'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(responseData['message'] ??
                                  'Gagal menambahkan kelas'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('HTTP Error ${response.statusCode}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Network Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text("Simpan"),
                )
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================================
  //                        EDIT KELAS
  // ==========================================================
  void _showEditKelas(int index, Map<String, dynamic> data) {
    TextEditingController namaKelasController =
        TextEditingController(text: data["Nama_Kelas"] ?? '');
    TextEditingController tahunAjarController =
        TextEditingController(text: data["Tahun_Ajar"] ?? tahunAjaran);

    int? selectedGuruUtamaId =
        data['Guru_Utama_Id'] is int ? data['Guru_Utama_Id'] : null;
    int? selectedGuruPendampingId =
        data['Guru_Pendamping_Id'] is int ? data['Guru_Pendamping_Id'] : null;

    // Variabel untuk kontrol tampilan
    bool editGuruUtama = false;
    bool editGuruPendamping = false;
    String namaGuruUtama = data['Guru_Utama'] ?? '-';
    String namaGuruPendamping = data['Guru_Pendamping'] ?? 'Tidak ada';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text("Edit Kelas"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Input Nama Kelas
                    TextField(
                      controller: namaKelasController,
                      decoration: const InputDecoration(
                        labelText: "Nama Kelas",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Tahun Ajar
                    TextField(
                      controller: tahunAjarController,
                      decoration: const InputDecoration(
                        labelText: "Tahun Ajar",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Guru Utama
                    const Text(
                      "Guru Utama:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    if (!editGuruUtama)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(namaGuruUtama),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  editGuruUtama = true;
                                });
                              },
                              child: const Text("Ubah"),
                            )
                          ],
                        ),
                      )
                    else
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Pilih Guru Utama",
                        ),
                        value: selectedGuruUtamaId,
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text("Pilih Guru Utama"),
                          ),
                          ...dataGuru.map<DropdownMenuItem<int>>((guru) {
                            return DropdownMenuItem<int>(
                              value: guru['Guru_Id'],
                              child: Text(guru['Nama'] ?? 'Unknown'),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedGuruUtamaId = value;
                          });
                        },
                      ),

                    const SizedBox(height: 16),

                    // Guru Pendamping
                    const Text(
                      "Guru Pendamping:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    if (!editGuruPendamping)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(namaGuruPendamping),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  editGuruPendamping = true;
                                });
                              },
                              child: const Text("Ubah"),
                            )
                          ],
                        ),
                      )
                    else
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Pilih Guru Pendamping",
                        ),
                        value: selectedGuruPendampingId,
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text("Tidak ada"),
                          ),
                          ...dataGuru.map<DropdownMenuItem<int>>((guru) {
                            return DropdownMenuItem<int>(
                              value: guru['Guru_Id'],
                              child: Text(guru['Nama'] ?? 'Unknown'),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedGuruPendampingId = value;
                          });
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (namaKelasController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Nama kelas harus diisi"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (selectedGuruUtamaId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Guru utama harus dipilih"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final Map<String, dynamic> requestData = {
                      'Nama_Kelas': namaKelasController.text,
                      'Tahun_Ajar': tahunAjarController.text,
                    };

                    // Tambahkan data guru hanya jika diubah
                    if (editGuruUtama && selectedGuruUtamaId != null) {
                      requestData['Guru_Utama_Id'] = selectedGuruUtamaId;
                    }

                    if (editGuruPendamping) {
                      requestData['Guru_Pendamping_Id'] =
                          selectedGuruPendampingId;
                    }

                    try {
                      final kelasId = data['Kelas_Id'];
                      final response = await http.put(
                        Uri.parse(
                            '${ApiConfig.baseUrl}/api/admin/kelas/update/$kelasId'),
                        headers: {
                          'Content-Type': 'application/json',
                          'Accept': 'application/json',
                          if (authToken != null)
                            'Authorization': 'Bearer $authToken',
                        },
                        body: jsonEncode(requestData),
                      );

                      if (response.statusCode == 200) {
                        final Map<String, dynamic> responseData =
                            jsonDecode(response.body);
                        if (responseData['success'] == true) {
                          Navigator.pop(context);
                          await fetchKelas();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(responseData['message'] ??
                                  'Kelas berhasil diupdate'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(responseData['message'] ??
                                  'Gagal mengupdate kelas'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('HTTP Error ${response.statusCode}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Network Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text("Update"),
                )
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================================
  //                        HAPUS KELAS
  // ==========================================================
  void _hapusKelas(int index, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: Text("Yakin ingin menghapus kelas ${data['Nama_Kelas']}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final kelasId = data['Kelas_Id'];
                final response = await http.delete(
                  Uri.parse(
                      '${ApiConfig.baseUrl}/api/admin/kelas/delete/$kelasId'),
                  headers: {
                    'Accept': 'application/json',
                    if (authToken != null) 'Authorization': 'Bearer $authToken',
                  },
                );

                if (response.statusCode == 200) {
                  final Map<String, dynamic> responseData =
                      jsonDecode(response.body);
                  if (responseData['success'] == true) {
                    Navigator.pop(context);
                    await fetchKelas();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(responseData['message'] ??
                            'Kelas berhasil dihapus'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(responseData['message'] ??
                            'Gagal menghapus kelas'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('HTTP Error ${response.statusCode}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Network Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
    // Ekstrak daftar kelas unik untuk filter
    List<String> kelasOptions = ["Semua"];

    final uniqueKelasSet = <String>{};

    for (var k in dataKelas) {
      final nama = k['Nama_Kelas']?.toString() ?? '';
      if (nama.isNotEmpty) {
        uniqueKelasSet.add(nama);
      }
    }

    kelasOptions.addAll(uniqueKelasSet.toList()..sort());

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 22,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Data Kelas",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF465940),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Kelola Data Kelas Sekolah",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildFilterBar(kelasOptions),
                        const SizedBox(height: 18),
                        if (isLoading)
                          const Expanded(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (filteredData.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(
                                'Tidak ada data kelas untuk $tahunAjaran',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: GridView.builder(
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 520,
                                crossAxisSpacing: 22,
                                mainAxisSpacing: 22,
                                mainAxisExtent: 400,
                              ),
                              itemCount: filteredData.length,
                              itemBuilder: (context, index) {
                                return _buildKelasCard(
                                  filteredData[index],
                                  index,
                                );
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
            child: Icon(
              Icons.person,
              color: Color(0xFF465940),
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, $adminName!",
                style: TextStyle(
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
        ],
      ),
    );
  }

  Widget _buildFilterBar(List<String> kelasOptions) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox.shrink(),
        Row(
          children: [
            const Text(
              "Pilih Tahun Ajaran : ",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            _dropdown(
              tahunAjaran,
              ["2023/2024", "2024/2025", "2025/2026"],
              (v) => setState(() => tahunAjaran = v!),
            ),
            const SizedBox(width: 16),
            const Text(
              "Pilih Kelas : ",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            _dropdown(
              kelasDipilih,
              kelasOptions,
              (v) => setState(() => kelasDipilih = v!),
            ),
            const SizedBox(width: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF465940),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              onPressed: _showTambahKelas,
              child: const Text(
                "+ Tambah Kelas",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dropdown(
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
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
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildKelasCard(Map<String, dynamic> data, int index) {
    final hovering = _hovering.contains(index);

    final siswa = (data['Siswa'] ?? []) as List;
    final guruUtama = data['Guru_Utama'] ?? '-';
    final guruPendamping = data['Guru_Pendamping'] ?? '-';
    final hasPendamping =
        guruPendamping.isNotEmpty && guruPendamping != '-';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering.add(index)),
      onExit: (_) => setState(() => _hovering.remove(index)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, hovering ? -6 : 0.0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF465940).withOpacity(0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(hovering ? 0.12 : 0.05),
              blurRadius: hovering ? 14 : 8,
              offset: Offset(0, hovering ? 8 : 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== HEADER =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['Nama_Kelas'] ?? '-',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF465940),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tahun ajar ${data['Tahun_Ajar'] ?? '-'}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                _jumlahSiswaBadge(data['Jumlah_Siswa'] ?? 0),
              ],
            ),
            const SizedBox(height: 14),

            // ===== INFO GURU =====
            _infoGuru(guruUtama, guruPendamping, hasPendamping),
            const SizedBox(height: 14),

            // ===== DAFTAR SISWA (AUTO HEIGHT) =====
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daftar Siswa",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF465940),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (siswa.isEmpty)
                    const Text(
                      "Belum ada siswa",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    )
                  else
                    ...siswa.map((s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            "• $s",
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ===== AKSI =====
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionIconButton(
                  Icons.edit,
                  onPressed: () => _showEditKelas(index, data),
                ),
                const SizedBox(width: 10),
                _actionIconButton(
                  Icons.delete,
                  color: Colors.redAccent,
                  onPressed: () => _hapusKelas(index, data),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _jumlahSiswaBadge(int jumlah) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B6B46), Color(0xFF465940)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            '$jumlah',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.people, size: 14, color: Colors.white),
        ],
      ),
    );
  }

  Widget _infoGuru(
    String utama,
    String pendamping,
    bool hasPendamping,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF465940).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _guruRow(
            Icons.school,
            "Guru Utama",
            utama,
            color: const Color(0xFF465940),
          ),
          if (hasPendamping) ...[
            const Divider(height: 16),
            _guruRow(
              Icons.group,
              "Guru Pendamping",
              pendamping,
              color: Colors.blue,
            ),
          ],
        ],
      ),
    );
  }

  Widget _guruRow(
    IconData icon,
    String label,
    String value, {
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSiswaPreview(List siswa) {
    final int limit = siswa.length >= 3 ? 3 : siswa.length;
    return List.generate(limit, (i) {
      return Row(
        children: [
          const Text("• ", style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              siswa[i]?.toString() ?? '-',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    });
  }

  Widget _actionIconButton(
    IconData icon, {
    Color? color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color == null
              ? Colors.grey.shade100
              : color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: color ?? const Color(0xFF465940),
        ),
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page!),
      );
    }
  }
}
