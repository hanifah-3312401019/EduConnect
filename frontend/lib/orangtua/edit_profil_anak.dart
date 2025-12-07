import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String baseUrl = "http://localhost:8000/api";
String globalAuthToken = '';

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
    namaController = TextEditingController(
      text: widget.data?['nama_anak'] ?? '',
    );
    ekskulController = TextEditingController(
      text: (widget.data?['ekskul'] is Map)
          ? widget.data!['ekskul']['nama']?.toString() ?? ''
          : widget.data?['ekskul']?.toString() ?? '',
    );
    tglController = TextEditingController(
      text: widget.data?['tgl_lahir'] ?? '',
    );
    alamatController = TextEditingController(
      text: widget.data?['alamat_anak'] ?? '',
    );

    // FIX: Handle jenis kelamin mapping
    String? jkFromData = widget.data?['jenis_kelamin']?.toString();
    if (jkFromData == 'L') {
      jenisKelamin = 'Laki-laki';
    } else if (jkFromData == 'P') {
      jenisKelamin = 'Perempuan';
    } else {
      jenisKelamin = 'Laki-laki'; // default
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

        final response = await http.post(
          Uri.parse('$baseUrl/profil/update-anak'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'nama_anak': namaController.text,
            'ekskul': ekskulController.text,
            'tgl_lahir': tglController.text,
            'jenis_kelamin': jkForBackend, // FIX: Kirim 'L' atau 'P'
            'agama': agama,
            'alamat_anak': alamatController.text,
          }),
        );

        print("Save Response: ${response.statusCode} - ${response.body}");

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

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF465940);
    const Color backgroundColor = Color(0xFFFDFBF0);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Data Anak",
          style: TextStyle(color: Colors.black, fontSize: 16),
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
                _buildTextField("Ekstrakulikuler", ekskulController),
                const SizedBox(height: 16),
                _buildTextField("Tanggal Lahir (YYYY-MM-DD)", tglController),
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
                    onPressed: saveAnak,
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
