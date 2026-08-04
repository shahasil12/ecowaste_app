import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/api_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> _citizens = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApiService.getLeaderboard();
    setState(() {
      _citizens = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏆 Leaderboard')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.card,
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _citizens.length,
                itemBuilder: (context, i) {
                  final c = _citizens[i];
                  final rank = i + 1;
                  return _LeaderboardTile(rank: rank, citizen: c);
                },
              ),
            ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> citizen;

  const _LeaderboardTile({required this.rank, required this.citizen});

  Color get _rankColor {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppTheme.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: rank <= 3 ? _rankColor.withOpacity(0.07) : AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rank <= 3 ? _rankColor.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _rankColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: rank <= 3
                ? Text(
                    ['🥇', '🥈', '🥉'][rank - 1],
                    style: const TextStyle(fontSize: 20),
                  )
                : Text(
                    '#$rank',
                    style: TextStyle(
                      color: _rankColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          // Avatar
          CircleAvatar(
            backgroundColor: AppTheme.primary.withOpacity(0.15),
            child: Text(
              (citizen['username'] as String).substring(0, 1).toUpperCase(),
              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          // Name & place
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  citizen['username'],
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  citizen['place'] ?? '',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${citizen['points']}',
                style: TextStyle(
                  color: _rankColor == AppTheme.textSecondary ? AppTheme.primary : _rankColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text('pts', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
