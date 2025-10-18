import 'package:flutter/material.dart';
import 'guru/dashboard_guru.dart';
import 'guru/permohonan_izin.dart'; 
import 'guru/absensi.dart';
import 'guru/pengumuman.dart';

void main() {
  runApp(EduConnectApp());
}

class EduConnectApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduConnect',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFFDFBF0),
        primaryColor: const Color(0xFF465940),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF465940),
          primary: const Color(0xFF465940),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF465940),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF465940),
          ),
          displayMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF465940),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ),
      home: DashboardGuru(), // Diubah dari LoginPage() ke DashboardGuru()
      routes: {
        '/guru/dashboard': (context) => DashboardGuru(),
        '/guru/permohonan-izin': (context) => const PermohonanIzin(), 
        '/guru/absensi': (context) => const Absensi(),
        '/guru/pengumuman': (context) => const Pengumuman(),
      },
    );
  }
}