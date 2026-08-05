import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  List<dynamic> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(Uri.parse(adminReportsUrl), headers: headers);
      if (res.statusCode == 200) {
        if (mounted) setState(() => _reports = jsonDecode(res.body));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteReport(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A3B5C),
        title: const Text('Delete Report?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.white))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );

    if (confirm != true) return;

    final headers = await AuthService.authHeaders();
    final res = await http.delete(Uri.parse('$adminReportsUrl$id/'), headers: headers);
    if (res.statusCode == 204) {
      _fetchReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Reports')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final r = _reports[index];
                return Card(
                  color: const Color(0xFF0A1929),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: AppTheme.primary, child: Icon(Icons.report, color: Colors.black)),
                    title: Text('${r['waste_type']} - ${r['status']}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                    subtitle: Text('${r['place']} \nBy: ${r['reported_by']?['username'] ?? 'Unknown'}', style: const TextStyle(color: AppTheme.textSecondary)),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.error),
                      onPressed: () => _deleteReport(r['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
