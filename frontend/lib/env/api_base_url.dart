import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
    // Jika project dibuka di Chrome / Flutter Web
      return "http://127.0.0.1:8000";
    } else {
    // Ganti dengan IP VPS dan Port yang digunakan
    // Jika Laravel dijalankan dengan 'php artisan serve', defaultnya port 8000
    // Tapi sesuaikan dengan port yang terbuka di VPS (misal 43765)
    return "http://151.243.222.93:43765";
    }
  }
}
