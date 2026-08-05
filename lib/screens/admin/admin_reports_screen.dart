import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class AdminReportsScreen extends StatefulWidget {
  final bool hideAppBar;
  const AdminReportsScreen({super.key, this.hideAppBar = false});

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

  Future<void> _editReport(Map<String, dynamic> report) async {
    final companies = await ApiService.getCompanies();
    if (!mounted) return;

    int? selectedCompanyId = report['assigned_company'];
    String selectedStatus = report['status'] ?? 'Pending';
    final statuses = ['Pending', 'In Progress', 'Resolved'];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A3B5C),
              title: const Text('Edit Report', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status:', style: TextStyle(color: Colors.white70)),
                    DropdownButton<String>(
                      value: selectedStatus,
                      dropdownColor: const Color(0xFF0A1929),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white),
                      items: statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setModalState(() => selectedStatus = val!),
                    ),
                    const SizedBox(height: 16),
                    const Text('Assign Company:', style: TextStyle(color: Colors.white70)),
                    DropdownButton<int?>(
                      value: selectedCompanyId,
                      dropdownColor: const Color(0xFF0A1929),
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white),
                      hint: const Text('Unassigned', style: TextStyle(color: Colors.white54)),
                      items: [
                        const DropdownMenuItem<int?>(value: null, child: Text('Unassigned')),
                        ...companies.map((c) => DropdownMenuItem<int?>(value: c['id'], child: Text(c['name']))),
                      ],
                      onChanged: (val) => setModalState(() => selectedCompanyId = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.white))),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save', style: TextStyle(color: AppTheme.primary))),
              ],
            );
          }
        );
      }
    );

    if (confirm != true) return;

    final headers = await AuthService.authHeaders();
    headers['Content-Type'] = 'application/json';
    final res = await http.patch(
      Uri.parse('$adminReportsUrl${report['id']}/'),
      headers: headers,
      body: jsonEncode({
        'status': selectedStatus,
        'assigned_company': selectedCompanyId,
      }),
    );

    if (res.statusCode == 200) {
      _fetchReports();
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update report')));
    }
  }

  Future<void> _deleteReport(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A3B5C),
        title: const Text('Delete Report?', style: TextStyle(color: Colors.white)),
        content: const Text('This action cannot be undone.', style: TextStyle(color: AppTheme.textSecondary)),
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
      appBar: widget.hideAppBar ? null : AppBar(title: const Text('Manage Reports')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _reports.isEmpty
              ? const Center(child: Text('No reports found.', style: TextStyle(color: AppTheme.textSecondary)))
              : ListView.builder(
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final r = _reports[index];
                final isAssigned = r['assigned_company'] != null;
                return Card(
                  color: const Color(0xFF0A1929),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: AppTheme.primary, child: Icon(Icons.report, color: Colors.black)),
                    title: Text('${r['waste_type']} - ${r['status']}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${r['place']} \nBy: ${r['reported_by']?['username'] ?? 'Unknown'}\nAssigned: ${r['assigned_company_name'] ?? 'None'}', 
                      style: const TextStyle(color: AppTheme.textSecondary)
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _editReport(r),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppTheme.error),
                          onPressed: () => _deleteReport(r['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
