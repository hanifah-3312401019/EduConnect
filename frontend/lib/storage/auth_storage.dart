import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  // ⛔ PAKAI KEY YANG SUDAH DIPAKAI LOGIN
  static const _tokenKey = 'token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    // DEBUG PENTING
    print('AUTH STORAGE TOKEN: $token');

    return token;
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
