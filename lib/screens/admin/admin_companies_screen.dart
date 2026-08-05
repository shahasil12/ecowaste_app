import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';

class AdminCompaniesScreen extends StatefulWidget {
  final bool hideAppBar;
  const AdminCompaniesScreen({super.key, this.hideAppBar = false});

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

  void _showAddEditCompanyDialog([Map<String, dynamic>? company]) {
    final isEdit = company != null;
    final nameCtrl = TextEditingController(text: company?['name'] ?? '');
    final addressCtrl = TextEditingController(text: company?['address'] ?? '');
    final emailCtrl = TextEditingController(text: company?['contact_email'] ?? '');
    final passwordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A3B5C),
        title: Text(isEdit ? 'Edit Company' : 'Add New Company', style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white)),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address', labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white)),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Contact Email', labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.emailAddress),
              TextField(controller: passwordCtrl, decoration: InputDecoration(labelText: isEdit ? 'New Password (leave blank to keep)' : 'Password', labelStyle: const TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white), obscureText: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white))),
          TextButton(
            onPressed: () async {
              final headers = await AuthService.authHeaders();
              headers['Content-Type'] = 'application/json';
              final body = {
                'name': nameCtrl.text,
                'address': addressCtrl.text,
                'contact_email': emailCtrl.text,
              };
              if (passwordCtrl.text.isNotEmpty) body['password'] = passwordCtrl.text;

              http.Response res;
              if (isEdit) {
                res = await http.put(Uri.parse('$adminCompaniesUrl${company['id']}/'), headers: headers, body: jsonEncode(body));
              } else {
                res = await http.post(Uri.parse(adminCompaniesUrl), headers: headers, body: jsonEncode(body));
              }

              if (res.statusCode == 201 || res.statusCode == 200) {
                if (mounted) Navigator.pop(ctx);
                _fetchCompanies();
              }
            },
            child: const Text('Save', style: TextStyle(color: AppTheme.primary)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hideAppBar ? null : AppBar(title: const Text('Manage Companies')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditCompanyDialog(),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _companies.isEmpty
              ? const Center(child: Text('No companies found.', style: TextStyle(color: AppTheme.textSecondary)))
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
                    subtitle: Text('${c['address']} • ${c['contact_email']}', style: const TextStyle(color: AppTheme.textSecondary)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _showAddEditCompanyDialog(c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppTheme.error),
                          onPressed: () => _deleteCompany(c['id']),
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
