import 'package:alter_ego/alter_ego.dart';
import 'package:alter_ego/alter_ego_service.dart';
import 'package:alter_ego/identity_replay_screen.dart';
import 'package:alter_ego/paywall_screen.dart';
import 'package:alter_ego/services/monetization_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _service = AlterEgoService();
  final _monetization = MonetizationService.instance;
  late Future<List<AlterEgoSnapshot>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identity Trends')),
      body: FutureBuilder<List<AlterEgoSnapshot>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final allHistory = snapshot.data!;
          if (allHistory.isEmpty) return const Center(child: Text('No history yet. Run a check-in first.'));

          final visibleCount = _monetization.applyHistoryLimit(allHistory.length);
          final history = allHistory.takeLast(visibleCount);

          final top = _top3(history);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Dominant pattern: ${top.first}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_summary(history)),
              const SizedBox(height: 24),
              SizedBox(height: 280, child: LineChart(_chartData(history, top))),
              const SizedBox(height: 16),
              if (_monetization.canAccess(PremiumFeature.weeklyEvolutionReport))
                Text('Weekly report: ${_weeklyReport(history)}')
              else ...[
                const Text('Weekly report is a Premium feature.', style: TextStyle(color: Colors.amber)),
                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen())),
                  child: const Text('Unlock Weekly Report'),
                ),
              ],
              const SizedBox(height: 8),
              Text('Milestone: ${_milestone(history)}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => IdentityReplayScreen(history: history))),
                child: const Text('Watch Identity Replay'),
              ),
              if (!_monetization.isPremium)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text('Free tier shows recent 7 data points only.', style: TextStyle(color: Colors.amber)),
                )
            ],
          );
        },
      ),
    );
  }

  String _summary(List<AlterEgoSnapshot> history) {
    final latest = [...history.last.egos]..sort((a, b) => b.leaning.compareTo(a.leaning));
    final top = latest.first;
    return 'Recently, ${top.name} has been leading. Counter-voice: ${latest.length > 1 ? latest[1].name : 'Unknown'}.';
  }

  String _weeklyReport(List<AlterEgoSnapshot> history) {
    if (history.length < 4) {
      return 'Need a few more check-ins to compute a weekly evolution report.';
    }
    final latestTop = [...history.last.egos]..sort((a, b) => b.leaning.compareTo(a.leaning));
    final previousTop = [...history[history.length - 4].egos]..sort((a, b) => b.leaning.compareTo(a.leaning));
    return latestTop.first.name == previousTop.first.name
        ? 'Your dominant voice stayed stable this week: ${latestTop.first.name}.'
        : 'Your dominant voice shifted this week from ${previousTop.first.name} to ${latestTop.first.name}.';
  }

  String _milestone(List<AlterEgoSnapshot> history) {
    if (history.length < 6) return 'Keep checking in to unlock shift milestones.';
    final latestTop = ([...history.last.egos]..sort((a, b) => b.leaning.compareTo(a.leaning))).first.name;
    final earlierTop = ([...history[history.length - 6].egos]..sort((a, b) => b.leaning.compareTo(a.leaning))).first.name;
    if (latestTop != earlierTop) {
      return 'Identity shift detected: $earlierTop → $latestTop.';
    }
    return 'Stability detected: $latestTop has remained dominant.';
  }

  List<String> _top3(List<AlterEgoSnapshot> history) {
    final totals = <String, double>{};
    for (final s in history) {
      for (final e in s.egos) {
        totals[e.name] = (totals[e.name] ?? 0) + e.leaning;
      }
    }
    final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toList();
  }

  LineChartData _chartData(List<AlterEgoSnapshot> history, List<String> top) {
    return LineChartData(
      minY: 0,
      maxY: 100,
      lineBarsData: List.generate(top.length, (i) {
        final name = top[i];
        final color = [Colors.cyanAccent, Colors.pinkAccent, Colors.amber][i % 3];
        return LineChartBarData(
          color: color,
          isCurved: true,
          spots: history.asMap().entries.map((e) {
            final ego = e.value.egos.where((x) => x.name == name).firstOrNull;
            return FlSpot(e.key.toDouble(), ((ego?.leaning ?? 0) * 100));
          }).toList(),
        );
      }),
      titlesData: const FlTitlesData(
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

extension _TakeLast<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}
