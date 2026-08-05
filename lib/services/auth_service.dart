import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';

class AuthService {
  static const _accessKey  = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _citizenKey = 'citizen_data';
  static const _companyKey = 'company_data';
  static const _roleKey    = 'user_role';

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

  static Future<void> saveCompany(Map<String, dynamic> company) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_companyKey, jsonEncode(company));
  }

  static Future<Map<String, dynamic>?> getCompany() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_companyKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
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
    await prefs.remove(_companyKey);
    await prefs.remove(_roleKey);
  }

  // ─── API Calls ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> unifiedLogin(String username, String password) async {
    final res = await http.post(
      Uri.parse(unifiedLoginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      await saveTokens(data['access'], data['refresh']);
      final role = data['role'] ?? 'citizen';
      await saveRole(role);
      
      if (role == 'citizen' && data['citizen'] != null) {
        await saveCitizen(data['citizen']);
      } else if (role == 'company' && data['company'] != null) {
        await saveCompany(data['company']);
      }
      // Admins don't currently have extra data saved here, but they could.
    }
    return {'status': res.statusCode, 'data': data};
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      await saveTokens(data['access'], data['refresh']);
      await saveRole(data['role'] ?? 'citizen');
      await saveCitizen(data['citizen']);
    }
    return {'status': res.statusCode, 'data': data};
  }

  static Future<Map<String, dynamic>> companyLogin(String name, String password) async {
    final res = await http.post(
      Uri.parse(companyLoginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'password': password}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      await saveTokens(data['access'], data['refresh']);
      await saveRole(data['role'] ?? 'company');
      await saveCompany(data['company']);
    }
    return {'status': res.statusCode, 'data': data};
  }

  static Future<Map<String, dynamic>> adminLogin(String username, String password) async {
    final res = await http.post(
      Uri.parse(adminLoginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      await saveTokens(data['access'], data['refresh']);
      await saveRole(data['role'] ?? 'admin');
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
      await saveRole(data['role'] ?? 'citizen');
      await saveCitizen(data['citizen']);
    }
    return {'status': res.statusCode, 'data': data};
  }

  static Future<Map<String, dynamic>> companyRegister({
    required String name,
    required String password,
    required String address,
    required String contactEmail,
  }) async {
    final res = await http.post(
      Uri.parse(companyRegisterUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'password': password,
        'address': address,
        'contact_email': contactEmail,
      }),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) {
      await saveTokens(data['access'], data['refresh']);
      await saveRole(data['role'] ?? 'company');
      await saveCompany(data['company']);
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
