import 'dart:io';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class PerizinanPage extends StatefulWidget {
  const PerizinanPage({super.key});

  @override
  State<PerizinanPage> createState() => _PerizinanPageState();
}

class _PerizinanPageState extends State<PerizinanPage> {
  final _formKey = GlobalKey<FormState>();
  String? _jenisIzin = 'Sakit';
  DateTime? _tanggal;
  final _alasanController = TextEditingController();
  
  // VARIABEL GAMBAR
  File? _buktiFileMobile;
  Uint8List? _buktiBytesWeb;
  String? _buktiFileName;
  
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;
  bool _loadingAnak = false;
  List<dynamic> _listAnak = [];
  String? _selectedAnakId;
  
  String get _baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000/api";
    } else {
      return "http://10.0.2.2:8000/api";
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAnakSaya();
  }

  Future<void> _loadAnakSaya() async {
    setState(() => _loadingAnak = true);
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/orangtua/perizinan/anak'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        },
      );
      
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _listAnak = data['data'] ?? [];
        });
      } else {
        _showError('Gagal memuat data anak');
      }
    } catch (e) {
      print('Error: $e');
      _showError('Error: $e');
    } finally {
      setState(() => _loadingAnak = false);
    }
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _pilihFotoGaleri() async {
    if (kIsWeb) {
      final html.InputElement input = html.InputElement(type: 'file')
        ..accept = 'image/*,application/pdf';
      
      input.click();
      
      input.onChange.listen((e) {
        final files = input.files;
        if (files != null && files.isNotEmpty) {
          final file = files[0];
          final reader = html.FileReader();
          
          reader.readAsArrayBuffer(file);
          reader.onLoadEnd.listen((e) {
            if (reader.readyState == html.FileReader.DONE) {
              setState(() {
                _buktiBytesWeb = reader.result as Uint8List;
                _buktiFileName = file.name;
              });
            }
          });
        }
      });
    } else {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (picked != null) {
        setState(() {
          _buktiFileMobile = File(picked.path);
          _buktiFileName = picked.name;
        });
      }
    }
  }

  Future<void> _kirimIzin() async {
    if (!_formKey.currentState!.validate()) {
      _showError('Harap lengkapi form');
      return;
    }
    
    if (_selectedAnakId == null) {
      _showError('Pilih anak terlebih dahulu');
      return;
    }
    
    if (_tanggal == null) {
      _showError('Pilih tanggal izin');
      return;
    }
    
    if (kIsWeb ? _buktiBytesWeb == null : _buktiFileMobile == null) {
      _showError('Upload bukti perizinan');
      return;
    }

    setState(() => _loading = true);
    
    try {
      final token = await _getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/orangtua/perizinan')
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      
      // Form fields
      request.fields['Siswa_Id'] = _selectedAnakId!;
      request.fields['Jenis'] = _jenisIzin!;
      request.fields['Keterangan'] = _alasanController.text.trim();
      request.fields['Tanggal_Izin'] = _tanggal!.toIso8601String().split('T')[0];
      
      // File
      if (kIsWeb && _buktiBytesWeb != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'Bukti',
          _buktiBytesWeb!,
          filename: _buktiFileName ?? 'bukti.jpg',
        ));
      } else if (!kIsWeb && _buktiFileMobile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'Bukti',
          _buktiFileMobile!.path,
          filename: _buktiFileName ?? 'bukti.jpg',
        ));
      }

      print('Sending to: $_baseUrl/orangtua/perizinan');
      print('Fields: ${request.fields}');
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 201) {
        final result = json.decode(response.body);
        _showSuccess(result['message'] ?? 'Perizinan berhasil dikirim!');
        _resetForm();
        // Kembali ke halaman sebelumnya
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        final error = json.decode(response.body);
        String errorMsg = error['message'] ?? 'Gagal mengirim perizinan';
        
        // Tampilkan error validasi jika ada
        if (error['errors'] != null) {
          final errors = error['errors'] as Map<String, dynamic>;
          errorMsg = errors.values.first[0];
        }
        
        _showError(errorMsg);
      }
    } catch (e) {
      print('Exception: $e');
      _showError('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _tanggal = null;
      _buktiFileMobile = null;
      _buktiBytesWeb = null;
      _buktiFileName = null;
      _jenisIzin = 'Sakit';
      _selectedAnakId = null;
      _alasanController.clear();
    });
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (kIsWeb) {
      return _buktiBytesWeb != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                _buktiBytesWeb!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
          : _buildEmptyUpload();
    } else {
      return _buktiFileMobile != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _buktiFileMobile!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
          : _buildEmptyUpload();
    }
  }

  Widget _buildEmptyUpload() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_upload, color: Color(0xFF465940), size: 40),
          SizedBox(height: 8),
          Text(
            "Upload Bukti Perizinan",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF465940),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "JPG, PNG, PDF (Max 5MB)",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const greenColor = Color(0xFF465940);
    const backgroundColor = Color(0xFFFDFBF0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: greenColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Formulir Perizinan",
          style: TextStyle(
            color: greenColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _loadingAnak
          ? const Center(child: CircularProgressIndicator())
          : _listAnak.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Belum ada data anak',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Silakan hubungi admin untuk\nmenambahkan data anak',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Ajukan Izin Siswa",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: greenColor,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // PILIH ANAK
                                const Text(
                                  "Pilih Anak *",
                                  style: TextStyle(
                                    color: greenColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedAnakId,
                                  decoration: _inputDecoration(
                                    hint: "Pilih anak...",
                                  ),
                                  items: _listAnak.map<DropdownMenuItem<String>>((anak) {
                                    return DropdownMenuItem<String>(
                                      value: anak['Siswa_Id'].toString(),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            anak['Nama'] ?? 'Tanpa Nama',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          if (anak['Kelas'] != null)
                                            Text(
                                              "Kelas: ${anak['Kelas']}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedAnakId = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Pilih anak terlebih dahulu';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // JENIS IZIN
                                const Text(
                                  "Jenis Izin *",
                                  style: TextStyle(
                                    color: greenColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _jenisIzin,
                                  decoration: _inputDecoration(
                                    hint: "Pilih jenis izin...",
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: "Sakit",
                                      child: Text("Sakit"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Acara Keluarga",
                                      child: Text("Acara Keluarga"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Lainnya",
                                      child: Text("Lainnya"),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() => _jenisIzin = value);
                                  },
                                ),
                                const SizedBox(height: 16),

                                // TANGGAL IZIN
                                const Text(
                                  "Tanggal Izin *",
                                  style: TextStyle(
                                    color: greenColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pilihTanggal,
                                  child: InputDecorator(
                                    decoration: _inputDecoration(
                                      hint: "Pilih tanggal...",
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _tanggal == null
                                              ? "Pilih tanggal..."
                                              : "${_tanggal!.day}/${_tanggal!.month}/${_tanggal!.year}",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: _tanggal == null
                                                ? Colors.grey[500]
                                                : Colors.black,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.calendar_today,
                                          color: greenColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // KETERANGAN
                                const Text(
                                  "Keterangan / Alasan *",
                                  style: TextStyle(
                                    color: greenColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _alasanController,
                                  maxLines: 4,
                                  minLines: 3,
                                  decoration: _inputDecoration(
                                    hint: "Tulis alasan izin dengan jelas...",
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Keterangan wajib diisi";
                                    }
                                    if (value.trim().length < 10) {
                                      return "Keterangan minimal 10 karakter";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // BUKTI PERIZINAN
                                const Text(
                                  "Bukti Perizinan *",
                                  style: TextStyle(
                                    color: greenColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _pilihFotoGaleri,
                                  child: Container(
                                    height: 160,
                                    decoration: BoxDecoration(
                                      color: greenColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: (kIsWeb
                                                ? _buktiBytesWeb
                                                : _buktiFileMobile) ==
                                            null
                                            ? greenColor.withOpacity(0.5)
                                            : Colors.green,
                                        width: 1,
                                      ),
                                    ),
                                    child: _buildImagePreview(),
                                  ),
                                ),
                                if (_buktiFileName != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          _buktiFileName!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _buktiFileMobile = null;
                                            _buktiBytesWeb = null;
                                            _buktiFileName = null;
                                          });
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 24),

                                // TOMBOL KIRIM
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _kirimIzin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: greenColor,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: _loading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3,
                                            ),
                                          )
                                        : const Text(
                                            "Kirim Permohonan Izin",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
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
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    const greenColor = Color(0xFF465940);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[500]),
      filled: true,
      fillColor: greenColor.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: greenColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: greenColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    );
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }
}