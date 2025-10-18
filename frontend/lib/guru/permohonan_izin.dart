import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/mobile_permohonan_izin.dart';  // dari widgets/
import '../widgets/web_permohonan_izin.dart';     // dari widgets/

class PermohonanIzin extends StatelessWidget {
  const PermohonanIzin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF0),
      appBar: AppBar(
        title: const Text(
          'Permohonan Izin',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF465940),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: const Sidebar(),
      body: const SafeArea(
        child: ResponsivePermohonanIzin(),
      ),
    );
  }
}

class ResponsivePermohonanIzin extends StatelessWidget {
  const ResponsivePermohonanIzin({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          return const MobilePermohonanIzin();
        } else {
          return const WebPermohonanIzin();
        }
      },
    );
  }
}