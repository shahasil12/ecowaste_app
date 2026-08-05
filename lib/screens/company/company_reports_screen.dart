import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';

class CompanyReportsScreen extends StatefulWidget {
  final bool hideAppBar;
  const CompanyReportsScreen({super.key, this.hideAppBar = false});

  @override
  State<CompanyReportsScreen> createState() => _CompanyReportsScreenState();
}

class _CompanyReportsScreenState extends State<CompanyReportsScreen> {
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
      final res = await http.get(Uri.parse(companyReportsUrl), headers: headers);
      if (res.statusCode == 200) {
        if (mounted) setState(() => _reports = jsonDecode(res.body));
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
          children: ['Pending', 'In Progress', 'Resolved'].map((status) {
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
      Uri.parse('$companyReportsUrl$id/'),
      headers: headers,
      body: jsonEncode({'status': newStatus}),
    );
    if (res.statusCode == 200) {
      _fetchReports();
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update status')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hideAppBar ? null : AppBar(title: const Text('Assigned Reports')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? const Center(child: Text('No assigned reports.', style: TextStyle(color: AppTheme.textSecondary)))
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
                        subtitle: Text('${r['place']}\nFee: ₹${r['fee']}', style: const TextStyle(color: AppTheme.textSecondary)),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.primary),
                          onPressed: () => _updateStatus(r['id'], r['status']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
