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
    return "http://192.168.1.52:8000";
    }
  }
}

class ApiBaseUrl {
  static String get baseUrl => '${ApiConfig.baseUrl}/api';


// HAPUS method helper, nanti pakai langsung di code
  // static String guruKelasSaya() => '$baseUrl/guru/kelas-saya';
  // static String guruPengumuman() => '$baseUrl/guru/pengumuman';
  // static String guruAgenda() => '$baseUrl/guru/agenda';
}

// final kelasResponse = await http.get(
//   Uri.parse('${ApiConfig.baseUrl}/api/guru/kelas-saya'),
//   headers: headers,
// );