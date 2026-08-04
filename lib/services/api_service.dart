import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import 'auth_service.dart';

class ApiService {
  // ─── Profile ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getProfile() async {
    final headers = await AuthService.authHeaders();
    final res = await http.get(Uri.parse(profileUrl), headers: headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    return null;
  }

  // ─── Reports ───────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getReports() async {
    final headers = await AuthService.authHeaders();
    final res = await http.get(Uri.parse(reportsUrl), headers: headers);
    if (res.statusCode == 200) return jsonDecode(res.body) as List;
    return [];
  }

  static Future<Map<String, dynamic>> submitReport({
    required String place,
    required String wasteType,
    required int fee,
    required File image,
    double? latitude,
    double? longitude,
  }) async {
    final token = await AuthService.getAccessToken();
    final request = http.MultipartRequest('POST', Uri.parse(reportsUrl));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['place'] = place;
    request.fields['waste_type'] = wasteType;
    request.fields['fee'] = fee.toString();
    if (latitude != null)  request.fields['latitude']  = latitude.toString();
    if (longitude != null) request.fields['longitude'] = longitude.toString();

    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return {'status': res.statusCode, 'data': jsonDecode(res.body)};
  }

  // ─── Bins ──────────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getBins() async {
    final res = await http.get(Uri.parse(binsUrl));
    if (res.statusCode == 200) return jsonDecode(res.body) as List;
    return [];
  }

  // ─── Recycling Centers ─────────────────────────────────────────────────────

  static Future<List<dynamic>> getRecyclingCenters() async {
    final res = await http.get(Uri.parse(centersUrl));
    if (res.statusCode == 200) return jsonDecode(res.body) as List;
    return [];
  }

  // ─── Leaderboard ───────────────────────────────────────────────────────────

  static Future<List<dynamic>> getLeaderboard() async {
    final res = await http.get(Uri.parse(leaderboardUrl));
    if (res.statusCode == 200) return jsonDecode(res.body) as List;
    return [];
  }

  // ─── Pickups ───────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getPickups() async {
    final headers = await AuthService.authHeaders();
    final res = await http.get(Uri.parse(pickupsUrl), headers: headers);
    if (res.statusCode == 200) return jsonDecode(res.body) as List;
    return [];
  }
}
