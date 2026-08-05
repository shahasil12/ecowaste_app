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
    int? companyId,
  }) async {
    final token = await AuthService.getAccessToken();
    final request = http.MultipartRequest('POST', Uri.parse(reportsUrl));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['place'] = place;
    request.fields['waste_type'] = wasteType;
    request.fields['fee'] = fee.toString();
    if (latitude != null)  request.fields['latitude']  = latitude.toString();
    if (longitude != null) request.fields['longitude'] = longitude.toString();
    if (companyId != null) request.fields['assigned_company'] = companyId.toString();

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
    final res = await http.get(Uri.parse(recyclingCentersUrl));
    if (res.statusCode == 200) return jsonDecode(res.body) as List;
    return [];
  }

  // ─── Companies ─────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getCompanies() async {
    final res = await http.get(Uri.parse('$baseUrl/companies/'));
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

  // ─── Dashboards ────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getAdminDashboardStats() async {
    try {
      final headers = await AuthService.authHeaders();
      final responses = await Future.wait([
        http.get(Uri.parse(adminCitizensUrl), headers: headers),
        http.get(Uri.parse(adminCompaniesUrl), headers: headers),
        http.get(Uri.parse(adminReportsUrl), headers: headers),
        http.get(Uri.parse(adminBinsUrl), headers: headers),
      ]);
      
      final citizens = responses[0].statusCode == 200 ? jsonDecode(responses[0].body) as List : [];
      final companies = responses[1].statusCode == 200 ? jsonDecode(responses[1].body) as List : [];
      final reports = responses[2].statusCode == 200 ? jsonDecode(responses[2].body) as List : [];
      final bins = responses[3].statusCode == 200 ? jsonDecode(responses[3].body) as List : [];

      return {
        'citizensCount': citizens.length,
        'companiesCount': companies.length,
        'reportsCount': reports.length,
        'binsCount': bins.length,
        'reports': reports,
      };
    } catch (e) {
      return {};
    }
  }

  static Future<Map<String, dynamic>> getCompanyDashboardStats() async {
    try {
      final headers = await AuthService.authHeaders();
      final responses = await Future.wait([
        http.get(Uri.parse(companyReportsUrl), headers: headers),
        http.get(Uri.parse(companyPickupsUrl), headers: headers),
      ]);
      
      final reports = responses[0].statusCode == 200 ? jsonDecode(responses[0].body) as List : [];
      final pickups = responses[1].statusCode == 200 ? jsonDecode(responses[1].body) as List : [];

      return {
        'reportsCount': reports.length,
        'pickupsCount': pickups.length,
        'reports': reports,
        'pickups': pickups,
      };
    } catch (e) {
      return {};
    }
  }
}
