import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/env/api_base_url.dart';

String baseUrl = "${ApiConfig.baseUrl}/api";
String globalAuthToken = '';

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
  bool isLoading = false;

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
      setState(() {
        isLoading = true;
      });

      try {
        final Map<String, dynamic> requestData = {
          'Nama': namaController.text,
          'No_Telepon': telpController.text,
          'Email': emailController.text,
          'Alamat': alamatController.text,
        };

        print('Data yang dikirim: $requestData');

        final response = await http.post(
          Uri.parse('$baseUrl/profil/update-ortu'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $globalAuthToken',
          },
          body: jsonEncode(requestData),
        );

        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'] ?? 'Data orang tua berhasil diperbarui',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          final errorData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menyimpan: ${errorData['message'] ?? response.body}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
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
                    onPressed: isLoading ? null : saveOrtu,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: greenColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
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
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label harus diisi';
          }
          return null;
        },
      ),
    );
  }
}
