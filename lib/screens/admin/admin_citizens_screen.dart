import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';

class AdminCitizensScreen extends StatefulWidget {
  const AdminCitizensScreen({super.key});

  @override
  State<AdminCitizensScreen> createState() => _AdminCitizensScreenState();
}

class _AdminCitizensScreenState extends State<AdminCitizensScreen> {
  List<dynamic> _citizens = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCitizens();
  }

  Future<void> _fetchCitizens() async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(Uri.parse(adminCitizensUrl), headers: headers);
      if (res.statusCode == 200) {
        if (mounted) setState(() => _citizens = jsonDecode(res.body));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteCitizen(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A3B5C),
        title: const Text('Delete Citizen?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.white))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );

    if (confirm != true) return;

    final headers = await AuthService.authHeaders();
    final res = await http.delete(Uri.parse('$adminCitizensUrl$id/'), headers: headers);
    if (res.statusCode == 204) {
      _fetchCitizens();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Citizens')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _citizens.length,
              itemBuilder: (context, index) {
                final c = _citizens[index];
                return Card(
                  color: const Color(0xFF0A1929),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: AppTheme.primary, child: Icon(Icons.person, color: Colors.black)),
                    title: Text(c['username'], style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                    subtitle: Text('${c['place']} • ${c['phone']}', style: const TextStyle(color: AppTheme.textSecondary)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.error),
                      onPressed: () => _deleteCitizen(c['id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
