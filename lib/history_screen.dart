import 'package:alter_ego/alter_ego.dart';
import 'package:alter_ego/alter_ego_service.dart';
import 'package:alter_ego/services/app_settings_service.dart';
import 'package:alter_ego/services/review_service.dart';
import 'package:alter_ego/services/share_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'identity_replay_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<AlterEgoSnapshot>> _historyFuture;
  final _alterEgoService = AlterEgoService();
  final _shareKey = GlobalKey();
  int? touchedIndex;

  @override
  void initState() {
    super.initState();
    _historyFuture = _alterEgoService.loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D0F14), // DARK GLOW
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Your Evolution'),
        actions: [
          IconButton(
            onPressed: () {
              ShareService.captureAndShare(
                context,
                _shareKey,
                text: 'Tracking my identity evolution over time. 100% private.',
                subject: 'My Identity Evolution',
              );
            },
            icon: const Icon(Icons.share, size: 20),
          ),
        ],
      ),
      body: FutureBuilder<List<AlterEgoSnapshot>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = snapshot.data!;
          final dominant = _getTopDominantEgos(history, 3);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              RepaintBoundary(
                key: _shareKey,
                child: Container(
                  color: const Color(0xff0D0F14), // Ensure background for capture
                  child: Column(
                    children: [
                      _DominantEgoCard(egoName: dominant.first),
                      const SizedBox(height: 16),
                      _WeeklySummaryCard(
                        summary: _generateWeeklySummary(history),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        height: 320,
                        child: LineChart(
                          _createChartData(history, dominant),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (touchedIndex != null)
                _InsightCard(
                  insight: _buildInsight(history, touchedIndex!, dominant.first),
                ),
              const SizedBox(height: 8),
              Text('Milestone: ${_milestone(history)}'),

              const SizedBox(height: 20),


              ElevatedButton(
                child: const Text("Watch Identity Replay"),
                onPressed: () async {
                  final settings = AppSettingsService();
                  final hasWatched = await settings.hasWatchedReplay();
                  
                  if (context.mounted) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IdentityReplayScreen(
                          history: history,
                        ),
                      ),
                    );
                    
                    if (!hasWatched) {
                      await settings.setHasWatchedReplay(true);
                      ReviewService.requestReview();
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
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


  // ==============================
  // CHART
  // ==============================

  LineChartData _createChartData(
      List<AlterEgoSnapshot> history,
      List<String> dominant,
      ) {
    final colors = [
      Colors.cyanAccent,
      Colors.pinkAccent,
      Colors.deepPurpleAccent,
    ];

    return LineChartData(
      minY: 0,
      maxY: 100,
      borderData: FlBorderData(show: false),

      gridData: FlGridData(
        show: true,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (_) => FlLine(
          color: Colors.white10,
          strokeWidth: 1,
        ),
      ),

      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            reservedSize: 32,
            getTitlesWidget: (value, meta) =>
                SideTitleWidget(meta: meta, child: Text('${value.toInt()}%', style: const TextStyle(color: Colors.white54))),
          ),
        ),

        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i >= history.length) return const SizedBox();
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  DateFormat.Md().format(history[i].timestamp),
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              );
            },
          ),
        ),

        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),

      lineTouchData: LineTouchData(
        touchCallback: (event, response) {
          if (response?.lineBarSpots != null) {
            setState(() {
              touchedIndex =
                  response!.lineBarSpots!.first.spotIndex;
            });
          }
        },
      ),

      lineBarsData: List.generate(dominant.length, (i) {
        final egoName = dominant[i];
        final color = colors[i];

        return LineChartBarData(
          spots: history.asMap().entries.map((e) {
            AlterEgo? ego;

            for (var x in e.value.egos) {
              if (x.name == egoName) {
                ego = x;
                break;
              }
            }

            return FlSpot(
              e.key.toDouble(),
              (ego?.leaning ?? 0) * 100,
            );
          }).toList(),

          isCurved: true,
          color: color,
          barWidth: 4,
          dotData: const FlDotData(show: false),

          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha:.35),
                color.withValues(alpha:.02),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        );
      }),
    );
  }

  // ==============================
  // INSIGHT ENGINE
  // ==============================

  String _buildInsight(
      List<AlterEgoSnapshot> history,
      int index,
      String dominant,
      ) {
    final date = DateFormat.yMMMd().format(history[index].timestamp);

    return "On $date you leaned strongly into $dominant.\n\nThis suggests a period where your decisions were guided by this side of your identity.";
  }

  // ==============================
  // WEEKLY SUMMARY ENGINE
  // ==============================

  String _generateWeeklySummary(List<AlterEgoSnapshot> history) {
    if (history.length < 2) {
      return "Your identity is still forming. Check in more often to unlock deeper insights.";
    }

    final latest = history.last;
    final theLatest = [...history.last.egos]..sort((a, b) => b.leaning.compareTo(a.leaning));
    AlterEgo top = latest.egos.first;

    for (var e in latest.egos) {
      if (e.leaning > top.leaning) {
        top = e;
      }
    }

    return "Recently, you have been leaning into ${top.name}. This suggests a shift in how you approach decisions and challenges. Counter-voice: ${theLatest.length > 1 ? theLatest[1].name : 'Unknown'}.";
  }

  // ==============================
  // HELPERS
  // ==============================

  List<String> _getTopDominantEgos(
      List<AlterEgoSnapshot> history,
      int limit,
      ) {
    final totals = <String, double>{};

    for (final s in history) {
      for (final e in s.egos) {
        totals[e.name] = (totals[e.name] ?? 0) + e.leaning;
      }
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).map((e) => e.key).toList();
  }
}

// ======================================================
// WIDGETS
// ======================================================

class _DominantEgoCard extends StatelessWidget {
  final String egoName;

  const _DominantEgoCard({required this.egoName});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Your dominant alter ego",
              style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 6),
          Text(egoName,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  final String summary;

  const _WeeklySummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Text(
        summary,
        style: const TextStyle(color: Colors.white70, height: 1.4),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: _GlassCard(
        child: Text(
          insight,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha:.08),
            Colors.white.withValues(alpha:.02),
          ],
        ),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }
}
