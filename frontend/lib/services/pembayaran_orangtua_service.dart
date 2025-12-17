import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pembayaran_orangtua.dart';
import '../env/api_base_url.dart';
import 'package:frontend/storage/auth_storage.dart';

class PembayaranOrangtuaService {
  static Future<PembayaranOrangtua> fetch({
    String? bulan,
    String? tahun,
  }) async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('Unauthorized: token tidak ditemukan');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/orangtua/pembayaran')
        .replace(
          queryParameters: {
            if (bulan != null) 'bulan': bulan,
            if (tahun != null) 'tahun': tahun,
          },
        );

    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json', // wajib
      },
    );

    if (res.statusCode == 200) {
      return PembayaranOrangtua.fromJson(jsonDecode(res.body));
    } else if (res.statusCode == 401) {
      throw Exception('Unauthorized: token tidak valid atau habis');
    } else {
      throw Exception('Gagal memuat data pembayaran: ${res.statusCode}');
    }
  }
}
