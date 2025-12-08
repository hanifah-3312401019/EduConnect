import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String baseUrl = "http://localhost:8000/api";

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

    namaController = TextEditingController(text: widget.data?['Nama'] ?? '');
    telpController = TextEditingController(
      text: widget.data?['No_Telepon'] ?? '',
    );
    emailController = TextEditingController(text: widget.data?['Email'] ?? '');
    alamatController = TextEditingController(
      text: widget.data?['Alamat'] ?? '',
    );
  }

  Future<void> saveOrtu() async {
    if (_formKey.currentState!.validate()) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        final response = await http.post(
          Uri.parse('$baseUrl/profil/update-ortu'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            "OrangTua_Id": widget.data?['OrangTua_Id'],
            "Nama": namaController.text,
            "No_Telepon": telpController.text,
            "Email": emailController.text,
            "Alamat": alamatController.text,
          }),
        );

        print("Save Response: ${response.statusCode} - ${response.body}");

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data orang tua berhasil diperbarui")),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menyimpan: ${response.body}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // ======== DIALOG KONFIRMASI ========
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
                        saveOrtu();
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

  // ======== UI MAIN ========
  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF465940);
    const Color backgroundColor = Color(0xFFFDFBF0);

    return Scaffold(
      backgroundColor: backgroundColor,

      // ======== HEADER ========
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: greenColor,
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  "Data Orang Tua",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 48), // title  center
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

                _buildField("Nama Orang Tua", namaController, isRequired: true),
                const SizedBox(height: 16),

                _buildField("No Telepon", telpController, isRequired: true),
                const SizedBox(height: 16),

                _buildField("Email", emailController, isRequired: true),
                const SizedBox(height: 16),

                _buildField("Alamat", alamatController, maxLines: 4),
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

  // ======== FIELD FORM ========
  Widget _buildField(
    String hint,
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
        decoration: InputDecoration(border: InputBorder.none, hintText: hint),
        validator: isRequired
            ? (v) => v == null || v.isEmpty ? '$hint harus diisi' : null
            : null,
      ),
    );
  }
}
