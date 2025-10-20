import 'package:flutter/material.dart';

class EditAnakPage extends StatelessWidget {
  const EditAnakPage({super.key});

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

              _buildRoundedTextField(label: "Nama Anak :"),
              const SizedBox(height: 16),

              _buildRoundedTextField(label: "Ekstrakulikuler : Basket"),
              const SizedBox(height: 16),

              _buildRoundedTextField(label: "Tanggal Lahir : 21 Mei 2009"),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: "Jenis Kelamin :",
                items: ["Laki-laki", "Perempuan"],
              ),
              const SizedBox(height: 16),

              _buildDropdownField(
                label: "Agama :",
                items: ["Islam", "Kristen", "Katolik", "Hindu", "Buddha"],
              ),
              const SizedBox(height: 16),

              _buildRoundedTextField(label: "Alamat :", maxLines: 4),
              const SizedBox(height: 30),

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

  static Widget _buildDropdownField({
    required String label,
    required List<String> items,
  }) {
    const Color greenColor = Color(0xFF465940);
    String? selectedValue;
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: greenColor, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedValue,
                    hint: Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue;
                      });
                    },
                    items: items.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          "$label $value",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
