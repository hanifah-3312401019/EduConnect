import 'package:flutter/material.dart';

class PengumumanPage extends StatelessWidget {
  const PengumumanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengumuman'),
        backgroundColor: const Color(0xFF465940),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Halaman Pengumuman - Dalam Pengembangan'),
      ),
    );
  }
}