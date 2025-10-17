import 'package:flutter/material.dart';
import 'orangtua/dashboard_orangtua.dart';
import 'orangtua/pembayaran.dart';
import 'auth/splash_screen.dart';
import 'auth/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduConnect',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 5, 62, 43),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(), // Start dengan splash screen
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => DashboardPage(),
        '/pembayaran': (context) => RincianPembayaranPage(),
      },
    );
  }
}