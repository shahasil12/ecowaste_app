import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({super.key});

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  Map<String, dynamic>? _companyData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    final data = await AuthService.getCompany();
    if (mounted) {
      setState(() {
        _companyData = data;
        _loading = false;
      });
    }
  }

  void _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = _companyData?['name'] ?? 'Company/Admin';
    final email = _companyData?['contact_email'] ?? 'No email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business, size: 80, color: AppTheme.primary),
            const SizedBox(height: 20),
            Text(
              'Welcome, $name!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 40),
            const Text(
              'Company/Admin controls will appear here.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
