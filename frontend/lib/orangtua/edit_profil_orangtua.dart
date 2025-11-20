import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String baseUrl = "http://10.0.2.2:8000/api";

class EditOrangTuaPage extends StatefulWidget {
  final Map<String, dynamic>? data;
  const EditOrangTuaPage({super.key, this.data});

  @override
  State<EditOrangTuaPage> createState() => _EditOrangTuaPageState();
}

class _EditOrangTuaPageState extends State<EditOrangTuaPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController namaController;
  late TextEditingController telpController;
  late TextEditingController emailController;
  late TextEditingController alamatController;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.data?['nama'] ?? '');
    telpController = TextEditingController(
      text: widget.data?['no_telepon'] ?? '',
    );
    emailController = TextEditingController(text: widget.data?['email'] ?? '');
    alamatController = TextEditingController(
      text: widget.data?['alamat'] ?? '',
    );
  }

  Future<void> saveOrtu() async {
    final response = await http.post(
      Uri.parse('$baseUrl/profil/update-ortu'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': widget.data?['orangTua_Id'], // Karena DB pakai OrangTua_Id
        'nama': namaController.text,
        'no_telepon': telpController.text,
        'email': emailController.text,
        'alamat': alamatController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data orang tua berhasil diperbarui')),
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
          "Data Orang Tua",
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
                _buildTextField("Nama Orang Tua", namaController),
                const SizedBox(height: 16),
                _buildTextField("No Telepon", telpController),
                const SizedBox(height: 16),
                _buildTextField("Email", emailController),
                const SizedBox(height: 16),
                _buildTextField("Alamat", alamatController, maxLines: 4),
                const SizedBox(height: 30),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: saveOrtu,
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
}
