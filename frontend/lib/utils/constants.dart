import 'package:flutter/material.dart';

class AppConstants {
  static const Color primaryColor = Color(0xFF053E2B);
  static const Color backgroundColor = Color(0xFFFDFBF0);
  
  static const String appName = 'EduConnect';
  static const String appSubtitle = 'Platform Komunikasi Sekolah & Orang Tua';
  
  static final formContainerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 30,
        offset: const Offset(0, 15),
      ),
    ],
    border: Border.all(
      color: Colors.grey.withOpacity(0.1),
      width: 1,
    ),
  );
  
  // SPLASH SCREEN CONSTANTS
  static const splashLogoSize = 150.0;
  static const splashLogoRadius = 35.0;
  static const splashDuration = Duration(seconds: 3);
}