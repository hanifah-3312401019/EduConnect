import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(0xFF465940),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Halaman Profil - Dalam Pengembangan'),
      ),
    );
  }
}