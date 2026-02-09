import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:alter_ego/alter_ego.dart';

import 'alter_ego_service.dart';

class IdentityReplayScreen extends StatefulWidget {
  final List<AlterEgoSnapshot> history;

  const IdentityReplayScreen({
    super.key,
    required this.history,
  });

  @override
  State<IdentityReplayScreen> createState() =>
      _IdentityReplayScreenState();
}

class _IdentityReplayScreenState
    extends State<IdentityReplayScreen> {
  int visiblePoints = 1;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startReplay();
  }

  void _startReplay() {
    timer?.cancel();

    timer = Timer.periodic(
      const Duration(milliseconds: 900),
          (_) {
        if (visiblePoints >= widget.history.length) {
          timer?.cancel();
          return;
        }

        setState(() {
          visiblePoints++;
        });
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // =============================

  @override
  Widget build(BuildContext context) {
    final visibleHistory =
    widget.history.take(visiblePoints).toList();

    final dominant = _getDominant(visibleHistory);

    return Scaffold(
      backgroundColor: const Color(0xff0B0D12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Identity Replay"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// LIVE DOMINANT TEXT
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                dominant,
                key: ValueKey(dominant),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Your identity is unfolding...",
              style: TextStyle(color: Colors.white.withValues(alpha:.6)),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: LineChart(
                _chartData(visibleHistory),
                duration: const Duration(milliseconds: 600),
              ),
            ),

            const SizedBox(height: 20),

            /// PROGRESS BAR
            LinearProgressIndicator(
              value: visiblePoints / widget.history.length,
              minHeight: 6,
              backgroundColor: Colors.white12,
              color: Colors.cyanAccent,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  visiblePoints = 1;
                });
                _startReplay();
              },
              child: const Text("Replay Again"),
            )
          ],
        ),
      ),
    );
  }

  // =============================
  // CHART
  // =============================

  LineChartData _chartData(
      List<AlterEgoSnapshot> history) {

    final egos = _top3(history);

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
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: Colors.white10),
      ),

      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            getTitlesWidget: (value, meta) =>
                SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '${value.toInt()}%',
                    style:
                    const TextStyle(color: Colors.white38),
                  ),
                ),
          ),
        ),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles:
        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),

      lineBarsData: List.generate(egos.length, (i) {
        final egoName = egos[i];
        final color = colors[i];

        return LineChartBarData(
          isCurved: true,
          color: color,
          barWidth: 4,
          dotData: const FlDotData(show: false),

          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha:.3),
                color.withValues(alpha:.02),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),

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
        );
      }),
    );
  }

  // =============================
  // HELPERS
  // =============================

  String _getDominant(List<AlterEgoSnapshot> history) {
    if (history.isEmpty) return "";

    final latest = history.last;

    AlterEgo top = latest.egos.first;

    for (var e in latest.egos) {
      if (e.leaning > top.leaning) {
        top = e;
      }
    }

    return top.name;
  }

  List<String> _top3(List<AlterEgoSnapshot> history) {
    final totals = <String, double>{};

    for (final s in history) {
      for (final e in s.egos) {
        totals[e.name] = (totals[e.name] ?? 0) + e.leaning;
      }
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(3).map((e) => e.key).toList();
  }
}
