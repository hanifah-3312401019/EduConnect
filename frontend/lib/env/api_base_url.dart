import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // Jika project dibuka di Chrome
      return "http://localhost:8000";
    } else {
      // Jika project dibuka dari Android emulator
      // return "http://10.0.2.2:8000";
      // CATATAN:
      // Untuk HP USB real device → nanti ganti ke IP WiFi laptop:
      return "http://192.168.43.115:8000";
    }
  }
}
