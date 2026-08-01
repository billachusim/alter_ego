import 'package:alter_ego/alter_ego.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ShareableIdentityCard extends StatelessWidget {
  final List<AlterEgo> egos;
  final String nickname;

  const ShareableIdentityCard({
    super.key,
    required this.egos,
    required this.nickname,
  });

  @override
  Widget build(BuildContext context) {
    final dominant = egos.isNotEmpty ? (egos..sort((a, b) => b.leaning.compareTo(a.leaning))).first : null;
    
    return Container(
      width: 400,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Color(0xFF101217),
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.5,
          colors: [Color(0xFF1B1F2B), Color(0xFF101217)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.blueAccent, size: 28),
              const SizedBox(width: 12),
              const Text(
                'ALTER EGO',
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 4,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildPrivacyBadge(),
            ],
          ),
          const SizedBox(height: 40),
          if (egos.length >= 3)
            SizedBox(
              height: 200,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.circle,
                  radarBorderData: const BorderSide(color: Colors.white10),
                  gridBorderData: const BorderSide(color: Colors.white10),
                  tickBorderData: const BorderSide(color: Colors.transparent),
                  ticksTextStyle: const TextStyle(color: Colors.transparent),
                  titleTextStyle: const TextStyle(color: Colors.white54, fontSize: 10),
                  getTitle: (index, angle) {
                    if (index >= egos.length) return const RadarChartTitle(text: '');
                    return RadarChartTitle(text: egos[index].name.split(' ').last);
                  },
                  dataSets: [
                    RadarDataSet(
                      fillColor: _getColorForEgo(dominant?.name ?? '').withAlpha(100),
                      borderColor: _getColorForEgo(dominant?.name ?? ''),
                      entryRadius: 3,
                      dataEntries: egos.map((e) => RadarEntry(value: e.leaning * 100)).toList(),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 40),
          Text(
            nickname.toUpperCase(),
            style: const TextStyle(color: Colors.white38, letterSpacing: 2, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (dominant != null)
            Text(
              'Dominant Identity: ${dominant.name}',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 24),
          const Text(
            'Mapped securely & locally. No data collection.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.greenAccent.withAlpha(40)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 10, color: Colors.greenAccent),
          SizedBox(width: 4),
          Text('PRIVATE', style: TextStyle(color: Colors.greenAccent, fontSize: 8, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getColorForEgo(String egoName) {
    switch (egoName) {
      case 'The Strategist': return Colors.blue;
      case 'The Rebel': return Colors.red;
      case 'The Caretaker': return Colors.green;
      case 'The Shadow': return Colors.purple;
      case 'The Achiever': return Colors.orange;
      case 'The Romantic': return Colors.pink;
      case 'The Protector': return Colors.teal;
      case 'The Analyst': return Colors.indigo;
      case 'The Escapist': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }
}
