import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'admin_citizens_screen.dart';
import 'admin_companies_screen.dart';
import 'admin_reports_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.admin_panel_settings, size: 80, color: AppTheme.primary),
            const SizedBox(height: 20),
            const Text(
              'Superuser Controls',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 40),
            _buildCard(context, 'Manage Citizens', Icons.people, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCitizensScreen()));
            }),
            _buildCard(context, 'Manage Companies', Icons.business, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCompaniesScreen()));
            }),
            _buildCard(context, 'Manage Reports', Icons.report, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminReportsScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1A3B5C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary, size: 30),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
