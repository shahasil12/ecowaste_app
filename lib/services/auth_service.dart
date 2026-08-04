import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class AuthService {
  static const _accessKey  = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _citizenKey = 'citizen_data';

  // ─── Token Storage ─────────────────────────────────────────────────────────

  static Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, access);
    await prefs.setString(_refreshKey, refresh);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  static Future<void> saveCitizen(Map<String, dynamic> citizen) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_citizenKey, jsonEncode(citizen));
  }

  static Future<Map<String, dynamic>?> getCitizen() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_citizenKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_citizenKey);
  }

  // ─── API Calls ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      await saveTokens(data['access'], data['refresh']);
      await saveCitizen(data['citizen']);
    }
    return {'status': res.statusCode, 'data': data};
  }

  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String phone,
    required String place,
  }) async {
    final res = await http.post(
      Uri.parse(registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
        'phone': phone,
        'place': place,
      }),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) {
      await saveTokens(data['access'], data['refresh']);
      await saveCitizen(data['citizen']);
    }
    return {'status': res.statusCode, 'data': data};
  }

  // ─── Authenticated Request Helper ──────────────────────────────────────────

  static Future<Map<String, String>> authHeaders() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Refresh the access token silently
  static Future<bool> refreshToken() async {
    final refresh = await getRefreshToken();
    if (refresh == null) return false;
    final res = await http.post(
      Uri.parse(tokenRefreshUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessKey, data['access']);
      return true;
    }
    return false;
  }
}
