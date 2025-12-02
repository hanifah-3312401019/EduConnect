import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // Jika project dibuka di Chrome / Flutter Web
      return "http://127.0.0.1:8000";
    } else {
      // Jika project dibuka dari Android Emulator
      // return "http://10.0.2.2:8000/api";

      // Jika pakai HP real device (USB/WiFi)
      return "http://192.168.43.115:8000";
    }
  }
}
