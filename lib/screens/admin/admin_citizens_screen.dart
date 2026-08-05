import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';

class AdminCitizensScreen extends StatefulWidget {
  final bool hideAppBar;
  const AdminCitizensScreen({super.key, this.hideAppBar = false});

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

  void _showAddEditCitizenDialog([Map<String, dynamic>? citizen]) {
    final isEdit = citizen != null;
    final usernameCtrl = TextEditingController(text: citizen?['username'] ?? '');
    final phoneCtrl = TextEditingController(text: citizen?['phone'] ?? '');
    final placeCtrl = TextEditingController(text: citizen?['place'] ?? '');
    final pointsCtrl = TextEditingController(text: citizen?['points']?.toString() ?? '0');
    final passwordCtrl = TextEditingController(); // Only needed for add, optional for edit

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A3B5C),
        title: Text(isEdit ? 'Edit Citizen' : 'Add New Citizen', style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'Username', labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white)),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone (10 digits)', labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white)),
              TextField(controller: placeCtrl, decoration: const InputDecoration(labelText: 'Place', labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white)),
              if (isEdit) TextField(controller: pointsCtrl, decoration: const InputDecoration(labelText: 'Points', labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number),
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
              final Map<String, dynamic> body = {
                'username': usernameCtrl.text,
                'phone': phoneCtrl.text,
                'place': placeCtrl.text,
              };
              if (isEdit) body['points'] = int.tryParse(pointsCtrl.text) ?? 0;
              if (passwordCtrl.text.isNotEmpty) body['password'] = passwordCtrl.text;

              http.Response res;
              if (isEdit) {
                res = await http.put(Uri.parse('$adminCitizensUrl${citizen['id']}/'), headers: headers, body: jsonEncode(body));
              } else {
                res = await http.post(Uri.parse(adminCitizensUrl), headers: headers, body: jsonEncode(body));
              }

              if (res.statusCode == 201 || res.statusCode == 200) {
                if (mounted) Navigator.pop(ctx);
                _fetchCitizens();
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
      appBar: widget.hideAppBar ? null : AppBar(title: const Text('Manage Citizens')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditCitizenDialog(),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _citizens.isEmpty
              ? const Center(child: Text('No citizens found.', style: TextStyle(color: AppTheme.textSecondary)))
              : ListView.builder(
              itemCount: _citizens.length,
              itemBuilder: (context, index) {
                final c = _citizens[index];
                return Card(
                  color: const Color(0xFF0A1929),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: AppTheme.primary, child: Icon(Icons.person, color: Colors.black)),
                    title: Text('${c['username']} (Pts: ${c['points']})', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                    subtitle: Text('${c['place']} • ${c['phone']}', style: const TextStyle(color: AppTheme.textSecondary)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _showAddEditCitizenDialog(c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppTheme.error),
                          onPressed: () => _deleteCitizen(c['id']),
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

