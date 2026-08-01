import 'package:alter_ego/alter_ego.dart';
import 'package:alter_ego/alter_ego_service.dart';
import 'package:alter_ego/content/offline_content_repository.dart';
import 'package:alter_ego/models/identity.dart';
import 'package:alter_ego/services/insight_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdviceScreen extends StatefulWidget {
  const AdviceScreen({super.key});

  @override
  State<AdviceScreen> createState() => _AdviceScreenState();
}

class _AdviceScreenState extends State<AdviceScreen> {
  late Future<List<Map<String, dynamic>>> _councilFuture;
  final _alterEgoService = AlterEgoService();
  final _insightService = InsightService();

  @override
  void initState() {
    super.initState();
    _councilFuture = _loadCouncilWithInsights();
  }

  Future<List<Map<String, dynamic>>> _loadCouncilWithInsights() async {
    final egos = await _alterEgoService.loadAlterEgos();
    egos.sort((a, b) => b.leaning.compareTo(a.leaning));
    final top3 = egos.take(3).toList();

    final results = <Map<String, dynamic>>[];
    for (var ego in top3) {
      final id = identityIdFromAny(ego.name) ?? IdentityId.shadow;
      final hint = await _insightService.getPatternHint(id);
      results.add({
        'ego': ego,
        'id': id,
        'hint': hint,
      });
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      appBar: AppBar(
        title: const Text('Inner Council Ranking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _councilFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final council = snapshot.data!;
          if (council.isEmpty) return const Center(child: Text('Your council is still forming.'));

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildInfluenceChart(council),
                const SizedBox(height: 32),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('COUNCIL GUIDANCE',
                      style: TextStyle(color: Colors.white38, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                ...council.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final ego = item['ego'] as AlterEgo;
                  final id = item['id'] as IdentityId;
                  final hint = item['hint'] as String?;

                  final advice = OfflineContentRepository.pickReply(
                    identity: id,
                    situationType: 'decision',
                    intensity: 'medium',
                    seed: DateTime.now().day + ego.leaning.hashCode,
                    historyHint: hint,
                  );

                  return _buildGlassAdviceCard(ego, advice, index);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfluenceChart(List<Map<String, dynamic>> council) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: PieChart(
        PieChartData(
          sectionsSpace: 8,
          centerSpaceRadius: 40,
          sections: council.map((item) {
            final ego = item['ego'] as AlterEgo;
            return PieChartSectionData(
              value: ego.leaning,
              color: _getColorForEgo(ego.name),
              title: '${(ego.leaning * 100).round()}%',
              radius: 50,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList(),
        ),
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildGlassAdviceCard(AlterEgo ego, String advice, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getColorForEgo(ego.name).withAlpha(30),
            Colors.white.withAlpha(5),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(ego.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(ego.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                child: Text('Rank #${index + 1}', style: const TextStyle(fontSize: 10, color: Colors.white54)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            advice,
            style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (200 * index).ms).slideY(begin: 0.1);
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
