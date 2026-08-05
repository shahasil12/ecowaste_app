import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';

class CompanyOverviewScreen extends StatefulWidget {
  final bool hideAppBar;
  const CompanyOverviewScreen({super.key, this.hideAppBar = false});

  @override
  State<CompanyOverviewScreen> createState() => _CompanyOverviewScreenState();
}

class _CompanyOverviewScreenState extends State<CompanyOverviewScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final stats = await ApiService.getCompanyDashboardStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _loading = false;
      });
    }
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A1929),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text('$count', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    final reportsCount = _stats?['reportsCount'] ?? 0;
    final pickupsCount = _stats?['pickupsCount'] ?? 0;
    
    final reports = _stats?['reports'] as List? ?? [];
    int pendingReports = 0;
    for (var r in reports) {
      if (r['status'] == 'Pending') pendingReports++;
    }

    final pickups = _stats?['pickups'] as List? ?? [];
    int pendingPickups = 0;
    for (var p in pickups) {
      if (p['status'] == 'Pending') pendingPickups++;
    }

    return Scaffold(
      appBar: widget.hideAppBar ? null : AppBar(title: const Text('Company Dashboard')),
      body: RefreshIndicator(
        onRefresh: _fetchStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard('Assigned Reports', reportsCount, Icons.report_problem, Colors.orangeAccent),
                  _buildStatCard('Scheduled Pickups', pickupsCount, Icons.local_shipping, Colors.blueAccent),
                  _buildStatCard('Pending Reports', pendingReports, Icons.warning_amber_rounded, Colors.redAccent),
                  _buildStatCard('Pending Pickups', pendingPickups, Icons.schedule, Colors.purpleAccent),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Task Distribution', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: (reportsCount == 0 && pickupsCount == 0)
                  ? const Center(child: Text('No assigned tasks yet', style: TextStyle(color: AppTheme.textSecondary)))
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(color: Colors.orangeAccent, value: reportsCount.toDouble(), title: '$reportsCount', radius: 50, titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          PieChartSectionData(color: Colors.blueAccent, value: pickupsCount.toDouble(), title: '$pickupsCount', radius: 50, titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
              ),
              if (reportsCount > 0 || pickupsCount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(children: [Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle)), const SizedBox(width: 4), const Text('Reports', style: TextStyle(color: AppTheme.textSecondary))]),
                      const SizedBox(width: 16),
                      Row(children: [Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle)), const SizedBox(width: 4), const Text('Pickups', style: TextStyle(color: AppTheme.textSecondary))]),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
