import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/api_service.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  List<dynamic> _reports = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final reports = await ApiService.getReports();
    setState(() {
      _reports = reports;
      _loading = false;
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Resolved':   return AppTheme.success;
      case 'In Progress': return AppTheme.warning;
      default:           return AppTheme.textSecondary;
    }
  }

  Color _typeColor(String type) {
    const map = {
      'Plastic': Color(0xFF29B6F6),
      'Organic': Color(0xFF66BB6A),
      'E-waste': Color(0xFFEF5350),
      'Metal':   Color(0xFF78909C),
      'Glass':   Color(0xFF26C6DA),
      'Other':   Color(0xFFBDBDBD),
    };
    return map[type] ?? AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.card,
              onRefresh: _load,
              child: _reports.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, color: AppTheme.textSecondary, size: 56),
                          SizedBox(height: 16),
                          Text('No reports yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                          Text('Tap the button below to report waste!',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _reports.length,
                      itemBuilder: (context, i) {
                        final r = _reports[i];
                        final status = r['status'] as String;
                        final type = r['waste_type'] as String;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _statusColor(status).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Image thumbnail
                              if (r['image'] != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    r['image'],
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 70,
                                      height: 70,
                                      color: AppTheme.cardLight,
                                      child: const Icon(Icons.broken_image, color: AppTheme.textSecondary),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: AppTheme.cardLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.image_not_supported, color: AppTheme.textSecondary),
                                ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: _typeColor(type).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            type,
                                            style: TextStyle(color: _typeColor(type), fontSize: 11, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: _statusColor(status).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(color: _statusColor(status), fontSize: 11, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      r['place'] ?? '',
                                      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Fee: ₹${r['fee']}',
                                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
