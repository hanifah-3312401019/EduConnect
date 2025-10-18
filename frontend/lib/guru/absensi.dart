import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/mobile_absensi.dart';  
import '../widgets/web_absensi.dart';     

class Absensi extends StatelessWidget {
  const Absensi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF0),
      appBar: AppBar(
        title: const Text(
          'Absensi',
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
        child: ResponsiveAbsensi(),
      ),
    );
  }
}

class ResponsiveAbsensi extends StatelessWidget {
  const ResponsiveAbsensi({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 768) {
          return const MobileAbsensi();
        } else {
          return const WebAbsensi();
        }
      },
    );
  }
}