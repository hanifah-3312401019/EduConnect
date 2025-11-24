import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String baseUrl = "http://192.168.43.115:8000/api";
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

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(
      text: widget.data?['nama_anak'] ?? '',
    );
    ekskulController = TextEditingController(
      text: widget.data?['ekskul'] ?? '',
    );
    tglController = TextEditingController(
      text: widget.data?['tgl_lahir'] ?? '',
    );
    alamatController = TextEditingController(
      text: widget.data?['alamat_anak'] ?? '',
    );
    jenisKelamin = widget.data?['jenis_kelamin'];
    agama = widget.data?['agama'];
  }

  Future<void> saveAnak() async {
    final response = await http.post(
      Uri.parse('$baseUrl/profil/update-anak'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': widget.data?['id'], // HARUS ADA DI API
        'nama_anak': namaController.text,
        'ekskul': ekskulController.text,
        'tgl_lahir': tglController.text,
        'jenis_kelamin': jenisKelamin,
        'agama': agama,
        'alamat_anak': alamatController.text,
      }),
    );

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
                _buildTextField("Nama Anak", namaController),
                const SizedBox(height: 16),
                _buildTextField("Ekstrakulikuler", ekskulController),
                const SizedBox(height: 16),
                _buildTextField("Tanggal Lahir", tglController),
                const SizedBox(height: 16),
                _buildDropdown(
                  "Jenis Kelamin",
                  ["Laki-laki", "Perempuan"],
                  jenisKelamin,
                  (val) => setState(() => jenisKelamin = val),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  "Agama",
                  ["Islam", "Kristen", "Katolik", "Hindu", "Buddha"],
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
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selected,
    ValueChanged<String?> onChanged,
  ) {
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
