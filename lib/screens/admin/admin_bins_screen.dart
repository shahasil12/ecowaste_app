import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';

class AdminBinsScreen extends StatefulWidget {
  final bool hideAppBar;
  const AdminBinsScreen({super.key, this.hideAppBar = false});

  @override
  State<AdminBinsScreen> createState() => _AdminBinsScreenState();
}

class _AdminBinsScreenState extends State<AdminBinsScreen> {
  List<dynamic> _bins = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchBins();
  }

  Future<void> _fetchBins() async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(Uri.parse(adminBinsUrl), headers: headers);
      if (res.statusCode == 200) {
        if (mounted) setState(() => _bins = jsonDecode(res.body));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteBin(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A3B5C),
        title: const Text('Delete Bin?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.white))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.error))),
        ],
      ),
    );

    if (confirm != true) return;

    final headers = await AuthService.authHeaders();
    final res = await http.delete(Uri.parse('$adminBinsUrl$id/'), headers: headers);
    if (res.statusCode == 204) {
      _fetchBins();
    }
  }

  void _showAddBinDialog() {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final latCtrl = TextEditingController();
    final lngCtrl = TextEditingController();
    final typesCtrl = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A3B5C),
        title: const Text('Add New Bin'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white)),
              TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Address', labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white)),
              TextField(controller: latCtrl, decoration: const InputDecoration(labelText: 'Latitude', labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number),
              TextField(controller: lngCtrl, decoration: const InputDecoration(labelText: 'Longitude', labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number),
              TextField(controller: typesCtrl, decoration: const InputDecoration(labelText: 'Types (e.g. Plastic, Glass)', labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final headers = await AuthService.authHeaders();
              headers['Content-Type'] = 'application/json';
              final res = await http.post(
                Uri.parse(adminBinsUrl),
                headers: headers,
                body: jsonEncode({
                  'name': nameCtrl.text,
                  'address': addressCtrl.text,
                  'latitude': double.tryParse(latCtrl.text) ?? 0.0,
                  'longitude': double.tryParse(lngCtrl.text) ?? 0.0,
                  'types': typesCtrl.text,
                  'status': 'Available'
                })
              );
              if (res.statusCode == 201) {
                if (mounted) Navigator.pop(ctx);
                _fetchBins();
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hideAppBar ? null : AppBar(title: const Text('Manage Bins')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBinDialog,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bins.isEmpty
              ? const Center(child: Text('No bins found.', style: TextStyle(color: AppTheme.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bins.length,
                  itemBuilder: (context, index) {
                    final b = _bins[index];
                    return Card(
                      color: const Color(0xFF0A1929),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.greenAccent, child: Icon(Icons.delete_outline, color: Colors.black)),
                        title: Text(b['name'], style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                        subtitle: Text('${b['address']} • ${b['status']}', style: const TextStyle(color: AppTheme.textSecondary)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: AppTheme.error),
                          onPressed: () => _deleteBin(b['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
