import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pembayaran_admin.dart';
import 'package:frontend/env/api_base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/storage/auth_storage.dart';

class PembayaranAdminService {
  static Future<List<PembayaranAdmin>> fetchAll() async {
    final token = await AuthStorage.getToken();

    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/admin/pembayaran'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print(res.statusCode); // ← TAMBAHIN DI SINI
    print(res.body);

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => PembayaranAdmin.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat pembayaran');
    }
  }

  static Future<void> delete(int id) async {
    final token = await AuthStorage.getToken();

    await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/admin/pembayaran/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }
}
