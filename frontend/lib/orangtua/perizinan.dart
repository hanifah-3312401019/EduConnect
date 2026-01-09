import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/env/api_base_url.dart';

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
  
  // VARIABEL FILE
  File? _buktiFile;
  String? _buktiFileName;
  
  bool _loading = false;
  bool _loadingAnak = false;
  List<dynamic> _listAnak = [];
  String? _selectedAnakId;
  
  // Menggunakan ApiBaseUrl.baseUrl yang sudah include /api
  String get _baseUrl => ApiBaseUrl.baseUrl;

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
      print('URL: $_baseUrl/orangtua/perizinan/anak');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _listAnak = data['data'] ?? [];
          // AUTO SELECT JIKA HANYA 1 ANAK
          if (_listAnak.length == 1) {
            _selectedAnakId = _listAnak[0]['Siswa_Id'].toString();
          }
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

  Future<void> _pilihFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        
        // Cek apakah file memiliki path
        if (file.path == null) {
          _showError('Gagal mengakses file');
          return;
        }
        
        // Cek ukuran file (maks 5MB)
        if (file.size > 5 * 1024 * 1024) {
          _showError('Ukuran file maksimal 5MB');
          return;
        }
        
        setState(() {
          _buktiFile = File(file.path!);
          _buktiFileName = file.name;
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      _showError('Gagal memilih file');
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
    
    if (_buktiFile == null) {
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
      request.files.add(await http.MultipartFile.fromPath(
        'Bukti',
        _buktiFile!.path,
        filename: _buktiFileName ?? 'bukti.jpg',
      ));

      print('Sending to: $_baseUrl/orangtua/perizinan');
      print('Fields: ${request.fields}');
      print('File: ${_buktiFile!.path}');
      
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
      _buktiFile = null;
      _buktiFileName = null;
      _jenisIzin = 'Sakit';
      // Jangan reset selectedAnakId karena sudah otomatis terpilih
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
    return _buktiFile != null
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                // Preview untuk PDF
                if (_buktiFileName != null && _buktiFileName!.toLowerCase().endsWith('.pdf'))
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 60,
                          color: Colors.red,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'File PDF',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                // Preview untuk gambar
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _buktiFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      _buktiFileName != null && _buktiFileName!.toLowerCase().endsWith('.pdf')
                          ? Icons.picture_as_pdf
                          : Icons.photo,
                      size: 16,
                      color: _buktiFileName != null && _buktiFileName!.toLowerCase().endsWith('.pdf')
                          ? Colors.red
                          : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          )
        : _buildEmptyUpload();
  }

  Widget _buildEmptyUpload() {
    const greenColor = Color(0xFF465940);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: greenColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              color: greenColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Upload Bukti Perizinan",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: greenColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "JPG, PNG, PDF (Maks 5MB)",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const greenColor = Color(0xFF465940);
    const backgroundColor = Color(0xFFFDFBF0);
    const lightGreen = Color(0xFFE9EFE5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: greenColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(greenColor),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Memuat data...',
                    style: TextStyle(
                      color: greenColor,
                    ),
                  ),
                ],
              ),
            )
          : _listAnak.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: greenColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            size: 50,
                            color: greenColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Belum ada data anak',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: greenColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Silakan hubungi admin untuk menambahkan data anak Anda ke dalam sistem',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // HEADER INFO
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: greenColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: greenColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                color: greenColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Informasi",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: greenColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Mohon isi formulir dengan data yang valid",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // FORM CARD
                      Form(
                        key: _formKey,
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: greenColor.withOpacity(0.1),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      color: greenColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Formulir Perizinan",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: greenColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // DATA ANAK SECTION
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    "Data Anak",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: greenColor,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: greenColor.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: greenColor.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: greenColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.person_outline,
                                          color: greenColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _listAnak.isNotEmpty 
                                                  ? _listAnak[0]['Nama'] ?? 'Tanpa Nama'
                                                  : 'Tidak ada data anak',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            if (_listAnak.isNotEmpty && _listAnak[0]['Kelas'] != null)
                                              Text(
                                                "Kelas ${_listAnak[0]['Kelas']}",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (_listAnak.length == 1)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 14,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                "Terpilih",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // JENIS IZIN
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    "Jenis Izin *",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: greenColor,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: _jenisIzin,
                                    decoration: _inputDecoration(
                                      hint: "Pilih jenis izin...",
                                    ),
                                    hint: const Text("Pilih jenis izin..."),
                                    items: const [
                                      DropdownMenuItem(
                                        value: "Sakit",
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.medical_services_outlined,
                                              size: 18,
                                              color: greenColor,
                                            ),
                                            SizedBox(width: 8),
                                            Text("Sakit"),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: "Acara Keluarga",
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.celebration_outlined,
                                              size: 18,
                                              color: greenColor,
                                            ),
                                            SizedBox(width: 8),
                                            Text("Acara Keluarga"),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: "Lainnya",
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.more_horiz,
                                              size: 18,
                                              color: greenColor,
                                            ),
                                            SizedBox(width: 8),
                                            Text("Lainnya"),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() => _jenisIzin = value);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // TANGGAL IZIN
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    "Tanggal Izin *",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: greenColor,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: _pilihTanggal,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 56,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: greenColor.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: greenColor.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              color: greenColor.withOpacity(0.7),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              _tanggal == null
                                                  ? "Pilih tanggal izin"
                                                  : "${_tanggal!.day}/${_tanggal!.month}/${_tanggal!.year}",
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: _tanggal == null
                                                    ? Colors.grey[500]
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: greenColor.withOpacity(0.7),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // KETERANGAN
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    "Keterangan / Alasan *",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: greenColor,
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  controller: _alasanController,
                                  maxLines: 4,
                                  minLines: 3,
                                  decoration: _inputDecoration(
                                    hint: "Tulis alasan izin dengan jelas...",
                                  ).copyWith(
                                    prefixIcon: const Icon(
                                      Icons.edit_outlined,
                                      color: greenColor,
                                      size: 20,
                                    ),
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
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 20),

                                // BUKTI PERIZINAN
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    "Bukti Perizinan *",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: greenColor,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _pilihFile,
                                  child: Container(
                                    height: 180,
                                    decoration: BoxDecoration(
                                      color: greenColor.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _buktiFile == null
                                            ? greenColor.withOpacity(0.2)
                                            : Colors.green.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: _buildImagePreview(),
                                    ),
                                  ),
                                ),
                                if (_buktiFileName != null) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _buktiFileName!.toLowerCase().endsWith('.pdf')
                                              ? Icons.picture_as_pdf
                                              : Icons.image,
                                          color: _buktiFileName!.toLowerCase().endsWith('.pdf')
                                              ? Colors.red
                                              : Colors.green,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "File terpilih:",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              Text(
                                                _buktiFileName!,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.grey[600],
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _buktiFile = null;
                                              _buktiFileName = null;
                                            });
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 30),

                                // TOMBOL KIRIM
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _loading ? null : _kirimIzin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: greenColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                      shadowColor: greenColor.withOpacity(0.3),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (_loading)
                                          const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        else
                                          const Icon(
                                            Icons.send_outlined,
                                            size: 20,
                                          ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _loading
                                              ? "Mengirim..."
                                              : "Kirim Permohonan Izin",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // FOOTER NOTE
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.lightbulb_outline,
                                        size: 14,
                                        color: greenColor.withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          "Permohonan akan diverifikasi oleh admin sekolah",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
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
                      ),
                    ],
                  ),
                ),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    const greenColor = Color(0xFF465940);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey[500],
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: greenColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: greenColor.withOpacity(0.2),
          width: 1.5,
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
          width: 1.5,
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
        vertical: 14,
      ),
    );
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }
}