import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';

class CompanyPickupsScreen extends StatefulWidget {
  const CompanyPickupsScreen({super.key});

  @override
  State<CompanyPickupsScreen> createState() => _CompanyPickupsScreenState();
}

class _CompanyPickupsScreenState extends State<CompanyPickupsScreen> {
  List<dynamic> _pickups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPickups();
  }

  Future<void> _fetchPickups() async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(Uri.parse(companyPickupsUrl), headers: headers);
      if (res.statusCode == 200) {
        if (mounted) setState(() => _pickups = jsonDecode(res.body));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(int id, String currentStatus) async {
    String? newStatus = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A3B5C),
        title: const Text('Update Status', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Pending', 'Assigned', 'Completed'].map((status) {
            return ListTile(
              title: Text(status, style: TextStyle(color: currentStatus == status ? AppTheme.primary : Colors.white)),
              onTap: () => Navigator.pop(ctx, status),
            );
          }).toList(),
        ),
      ),
    );

    if (newStatus == null || newStatus == currentStatus) return;

    final headers = await AuthService.authHeaders();
    final res = await http.patch(
      Uri.parse('$companyPickupsUrl$id/'),
      headers: headers,
      body: jsonEncode({'status': newStatus}),
    );
    if (res.statusCode == 200) {
      _fetchPickups();
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update status')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pickup Requests')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pickups.isEmpty
              ? const Center(child: Text('No pickup requests.', style: TextStyle(color: AppTheme.textSecondary)))
              : ListView.builder(
                  itemCount: _pickups.length,
                  itemBuilder: (context, index) {
                    final p = _pickups[index];
                    return Card(
                      color: const Color(0xFF0A1929),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: AppTheme.primary, child: Icon(Icons.local_shipping, color: Colors.black)),
                        title: Text('${p['waste_type']} - ${p['status']}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                        subtitle: Text('${p['address']}\nDate: ${p['pickup_date']}', style: const TextStyle(color: AppTheme.textSecondary)),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.primary),
                          onPressed: () => _updateStatus(p['id'], p['status']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
