import 'package:flutter/material.dart';
import 'package:frontend/orangtua/perizinan.dart';
import 'guru/dashboard_guru.dart';
import 'guru/permohonan_izin.dart';
import 'guru/absensi.dart';
import 'guru/pengumuman.dart' as guru;
import 'guru/agenda.dart';
import 'orangtua/dashboard_orangtua.dart';
import 'orangtua/jadwal.dart';
import 'orangtua/profil.dart';
import 'orangtua/pengumuman.dart' as ortu;
import 'orangtua/perizinan.dart';
import 'orangtua/edit_profil_anak.dart';
import 'orangtua/edit_profil_orangtua.dart';
import 'orangtua/pembayaran.dart';
import 'orangtua/agenda.dart';
import 'admin/data_orangTua.dart';
import 'admin/data_kelas.dart';
import 'admin/data_guru.dart';
import 'admin/data_siswa.dart';
import 'admin/dashboard_admin.dart';
import 'admin/jadwal_pelajaran.dart';
import 'admin/informasi_pembayaran.dart';
import 'auth/splash_screen.dart';
import 'auth/login.dart';

void main() {
  runApp(const EduConnectApp());
}

class EduConnectApp extends StatelessWidget {
  const EduConnectApp({super.key});

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
          brightness: Brightness.light,
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
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),

      // 🟢 SET INITIAL ROUTE UNTUK WEB
      initialRoute: '/',

      // 🟢 Halaman pertama dengan SplashScreen & authentication check
      home: const SplashScreen(),

      // 🧭 Daftar semua rute aplikasi
      routes: {
        '/login': (context) => const LoginPage(),
        '/guru/dashboard': (context) => const DashboardGuru(),
        '/guru/permohonan-izin': (context) => const PermohonanIzin(),
        '/guru/absensi': (context) => const Absensi(),
        '/guru/pengumuman': (context) => const guru.PengumumanPage(),
        '/guru/agenda': (context) => const Agenda(),
        '/dashboard': (context) => DashboardPage(),
        '/pembayaran': (context) => RincianPembayaranPage(),
        '/jadwal': (context) => JadwalPage(),
        '/profil': (context) => ProfilPage(),
        '/pengumuman': (context) => const ortu.PengumumanPage(),
        '/edit_profil_anak': (context) => EditAnakPage(),
        '/edit_profil_orangtua': (context) => EditOrangTuaPage(),
        '/agenda': (context) => const AgendaPage(),
        '/orangtua/perizinan': (context) => const PerizinanPage(),

        //--- ADMIN ---
        '/admin/dashboard': (context) => DashboardAdminPage(),
        '/admin/data_siswa': (context) => DataSiswaPage(),
        '/admin/data_orangtua': (context) => DataOrangTuaPage(),
        '/admin/data_kelas': (context) => DataKelasPage(),
        '/admin/data_guru': (context) => DataGuruPage(),
        '/admin/jadwal_pelajaran': (context) => JadwalPelajaranPage(),
        '/admin/informasi_pembayaran': (context) => DataPembayaranPage(),
      },
    );
  }
}
