import 'package:flutter/material.dart';

class JadwalPage extends StatelessWidget {
  const JadwalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF0),
        elevation: 0,
        title: const Text(
          "Jadwal Pelajaran",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF465940),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF465940)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHari("Hari Senin", [
            ["Matematika", "08:00-08:45"],
            ["Bahasa Indonesia", "08:45-09:30"],
            ["Olahraga", "10:00-10:45"],
            ["Agama", "10:45-11:30"],
          ]),
          _buildHari("Hari Selasa", [
            ["Bahasa Inggris", "08:00-08:45"],
            ["Mandarin", "08:45-09:30"],
            ["Pendidikan Pancasila", "10:00-10:45"],
            ["Seni Budaya", "10:45-11:30"],
          ]),
          _buildHari("Hari Rabu", [
            ["Ilmu Pengetahuan Alam", "08:00-08:45"],
            ["Ilmu Pengetahuan Sosial", "08:45-09:30"],
            ["Matematika", "10:00-10:45"],
          ]),
          _buildHari("Hari Kamis", [
            ["Bahasa Indonesia", "08:00-08:45"],
            ["Agama", "08:45-09:30"],
            ["PJOK", "10:00-10:45"],
            ["Seni Musik", "10:45-11:30"],
          ]),
          _buildHari("Hari Jumat", [
            ["Bahasa Inggris", "07:30-08:15"],
            ["Prakarya", "08:15-09:00"],
            ["Matematika", "09:30-10:15"],
          ]),
        ],
      ),
    );
  }

  Widget _buildHari(String hari, List<List<String>> jadwal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          hari,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF465940),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF465940),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: jadwal
                .map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            item[1],
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}