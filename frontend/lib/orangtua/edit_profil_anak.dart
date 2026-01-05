import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/env/api_base_url.dart';

class EditAnakPage extends StatefulWidget {
  final Map<String, dynamic>? data; // nullable
  const EditAnakPage({super.key, this.data});

  @override
  State<EditAnakPage> createState() => _EditAnakPageState();
}

class _EditAnakPageState extends State<EditAnakPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController namaController;
  late TextEditingController ekskulController;
  late TextEditingController tglController;
  late TextEditingController alamatController;

  int? idEkskul;
  String? jenisKelamin;
  String? agama;

  // FIX: List untuk dropdown dengan value yang sesuai
  final List<String> _jenisKelaminOptions = ['L', 'P'];
  final List<String> _agamaOptions = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
  ];

  @override
  void initState() {
    super.initState();

    print(widget.data);

    // Format tanggal
    String? rawDate = widget.data?['tgl_lahir']?.toString();
    String formattedDate = '';

    if (rawDate != null && rawDate.isNotEmpty) {
      if (rawDate.contains('T')) {
        try {
          DateTime date = DateTime.parse(rawDate);
          formattedDate =
              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        } catch (e) {
          formattedDate = rawDate;
        }
      } else {
        formattedDate = rawDate;
      }
    }

    // Inisialisasi SEMUA controller dengan data dari widget.data
    namaController = TextEditingController(
      text: widget.data?['nama_anak'] ?? '',
    );
    idEkskul = widget.data?['ekskul_id'];
    ekskulController = TextEditingController(
      text: widget.data?['ekskul_nama']?.toString() ?? '',
    );
    tglController = TextEditingController(
      text: formattedDate,
    ); // PAKAI formattedDate
    alamatController = TextEditingController(
      text: widget.data?['alamat_anak'] ?? '',
    );

    // Handle jenis kelamin
    String? jkFromData = widget.data?['jenis_kelamin']?.toString();
    if (jkFromData == 'L') {
      jenisKelamin = 'Laki-laki';
    } else if (jkFromData == 'P') {
      jenisKelamin = 'Perempuan';
    } else {
      jenisKelamin = 'Laki-laki';
    }

    agama = widget.data?['agama']?.toString() ?? 'Islam';
  }

  Future<void> saveAnak() async {
    if (_formKey.currentState!.validate()) {
      try {
        // FIX: Map jenis kelamin untuk backend
        String jkForBackend = 'L';
        if (jenisKelamin == 'Perempuan') {
          jkForBackend = 'P';
        }

        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        // GUNAKAN ApiConfig.baseUrl DARI FILE api_base_url.dart
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/profil/update-anak'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "OrangTua_Id": widget.data?['OrangTua_Id'],
            'nama_anak': namaController.text,
            'ekskul_id': idEkskul,
            'tgl_lahir': tglController.text,
            'jenis_kelamin': jkForBackend,
            'agama': agama,
            'alamat_anak': alamatController.text,
          }),
        );

        print("Save Response: ${response.statusCode} - ${response.body}");
        print("Menggunakan URL: ${ApiConfig.baseUrl}/api/profil/update-anak");

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data anak berhasil diperbarui')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildReadOnlyField(String label, String value) {
    const Color greenColor = Color(0xFF465940);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: greenColor,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: greenColor, width: 1.5),
            color: Colors.grey.shade200, // warna locked
          ),
          child: Text(
            value.isEmpty ? "-" : value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void showConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Konfirmasi Data",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Apakah anda yakin ingin menyimpan data ini?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Batal"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        saveAnak();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF465940),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Simpan"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF465940);
    const Color backgroundColor = Color(0xFFFDFBF0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: const Color(0xFF465940),
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  "Data Anak",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.person, size: 55, color: Colors.black),
                ),
                const SizedBox(height: 25),
                _buildTextField("Nama Anak", namaController, isRequired: true),
                const SizedBox(height: 16),
                _buildReadOnlyField("Ekstrakulikuler", ekskulController.text),
                const SizedBox(height: 16),
                _buildDatePickerField("Tanggal Lahir", tglController),
                const SizedBox(height: 16),

                // FIX: Dropdown Jenis Kelamin
                _buildDropdown(
                  "Jenis Kelamin",
                  ["Laki-laki", "Perempuan"],
                  jenisKelamin,
                  (val) => setState(() => jenisKelamin = val),
                  isRequired: true,
                ),
                const SizedBox(height: 16),

                // FIX: Dropdown Agama
                _buildDropdown(
                  "Agama",
                  _agamaOptions,
                  agama,
                  (val) => setState(() => agama = val),
                ),
                const SizedBox(height: 16),

                _buildTextField("Alamat", alamatController, maxLines: 4),
                const SizedBox(height: 30),

                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: showConfirmDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      "Simpan Data",
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool isRequired = false,
  }) {
    const Color greenColor = Color(0xFF465940);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: greenColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(border: InputBorder.none, hintText: label),
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return '$label harus diisi';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    const Color greenColor = Color(0xFF465940);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: greenColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: TextFormField(
        controller: controller,
        readOnly: true, // <-- supaya tidak bisa edit manual
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
            firstDate: DateTime(1990),
            lastDate: DateTime(2030),
          );

          if (pickedDate != null) {
            String formatted =
                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
            setState(() {
              controller.text = formatted;
            });
          }
        },
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selected,
    ValueChanged<String?> onChanged, {
    bool isRequired = false,
  }) {
    const Color greenColor = Color(0xFF465940);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: greenColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(label),
          value: selected,
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
        ),
      ),
    );
  }
}
