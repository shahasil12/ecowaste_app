import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../core/theme.dart';
import 'company/company_overview_screen.dart';
import 'company/company_reports_screen.dart';
import 'company/company_pickups_screen.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({super.key});

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _companyData;
  bool _loading = true;

  final List<Widget> _pages = [
    const CompanyOverviewScreen(hideAppBar: true),
    const CompanyReportsScreen(hideAppBar: true),
    const CompanyPickupsScreen(hideAppBar: true),
  ];

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    final company = await AuthService.getCompany();
    if (mounted) {
      setState(() {
        _companyData = company;
        _loading = false;
      });
    }
  }

  void _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final name = _companyData?['name'] ?? 'Company Portal';

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppTheme.surface,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondary,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.report_problem), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Pickups'),
        ],
      ),
    );
  }
}

