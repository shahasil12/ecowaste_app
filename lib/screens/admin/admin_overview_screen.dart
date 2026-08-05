import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../services/api_service.dart';

class AdminOverviewScreen extends StatefulWidget {
  final bool hideAppBar;
  const AdminOverviewScreen({super.key, this.hideAppBar = false});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final stats = await ApiService.getAdminDashboardStats();
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
    
    final citizensCount = _stats?['citizensCount'] ?? 0;
    final companiesCount = _stats?['companiesCount'] ?? 0;
    final reportsCount = _stats?['reportsCount'] ?? 0;
    final binsCount = _stats?['binsCount'] ?? 0;

    final reports = _stats?['reports'] as List? ?? [];
    int pending = 0, resolved = 0, inProgress = 0;
    for (var r in reports) {
      if (r['status'] == 'Pending') pending++;
      else if (r['status'] == 'Resolved') resolved++;
      else inProgress++;
    }

    return Scaffold(
      appBar: widget.hideAppBar ? null : AppBar(title: const Text('Admin Dashboard Overview')),
      body: RefreshIndicator(
        onRefresh: _fetchStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('System Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard('Total Citizens', citizensCount, Icons.people, Colors.blueAccent),
                  _buildStatCard('Total Companies', companiesCount, Icons.business, Colors.orangeAccent),
                  _buildStatCard('Total Reports', reportsCount, Icons.report, Colors.redAccent),
                  _buildStatCard('Total Bins', binsCount, Icons.delete_outline, Colors.greenAccent),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Reports Distribution', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 24),
              SizedBox(
                height: 200,
                child: reports.isEmpty 
                  ? const Center(child: Text('No reports data', style: TextStyle(color: AppTheme.textSecondary)))
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(color: Colors.redAccent, value: pending.toDouble(), title: '$pending', radius: 50, titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          PieChartSectionData(color: Colors.orangeAccent, value: inProgress.toDouble(), title: '$inProgress', radius: 50, titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          PieChartSectionData(color: Colors.greenAccent, value: resolved.toDouble(), title: '$resolved', radius: 50, titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
              ),
              if (reports.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegend(Colors.redAccent, 'Pending'),
                      const SizedBox(width: 16),
                      _buildLegend(Colors.orangeAccent, 'In Progress'),
                      const SizedBox(width: 16),
                      _buildLegend(Colors.greenAccent, 'Resolved'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: AppTheme.textSecondary)),
      ],
    );
  }
}
