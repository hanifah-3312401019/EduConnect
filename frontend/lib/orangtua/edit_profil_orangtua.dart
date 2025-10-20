import 'package:flutter/material.dart';

class EditOrangTuaPage extends StatelessWidget {
  const EditOrangTuaPage({super.key});

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
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 32,
                backgroundColor: Colors.transparent,
                child: Icon(Icons.person, size: 55, color: Colors.black),
              ),
              const SizedBox(height: 25),

              // Input Nama Orang Tua
              _buildRoundedTextField(label: "Nama Orang Tua :"),
              const SizedBox(height: 16),

              // Input No Telepon
              _buildRoundedTextField(label: "No Telepon :"),
              const SizedBox(height: 16),

              // Input Email
              _buildRoundedTextField(label: "Email :"),
              const SizedBox(height: 16),

              // Input Alamat (Lebih tinggi)
              _buildRoundedTextField(label: "Alamat :", maxLines: 4),
              const SizedBox(height: 30),

              // Tombol Simpan Data
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    "Simpan Data",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildRoundedTextField({
    required String label,
    int maxLines = 1,
  }) {
    const Color greenColor = Color(0xFF465940);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: greenColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
