import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';

class AdminCompaniesScreen extends StatefulWidget {
  const AdminCompaniesScreen({super.key});

  @override
  State<AdminCompaniesScreen> createState() => _AdminCompaniesScreenState();
}

class _AdminCompaniesScreenState extends State<AdminCompaniesScreen> {
  List<dynamic> _companies = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCompanies();
  }

  Future<void> _fetchCompanies() async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(Uri.parse(adminCompaniesUrl), headers: headers);
      if (res.statusCode == 200) {
        if (mounted) setState(() => _companies = jsonDecode(res.body));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteCompany(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A3B5C),
        title: const Text('Delete Company?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.white))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );

    if (confirm != true) return;

    final headers = await AuthService.authHeaders();
    final res = await http.delete(Uri.parse('$adminCompaniesUrl$id/'), headers: headers);
    if (res.statusCode == 204) {
      _fetchCompanies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Companies')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _companies.length,
              itemBuilder: (context, index) {
                final c = _companies[index];
                return Card(
                  color: const Color(0xFF0A1929),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: AppTheme.primary, child: Icon(Icons.business, color: Colors.black)),
                    title: Text(c['name'], style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                    subtitle: Text('${c['contact_email']}', style: const TextStyle(color: AppTheme.textSecondary)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.error),
                      onPressed: () => _deleteCompany(c['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
