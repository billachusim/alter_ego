import 'package:alter_ego/alter_ego.dart';
import 'package:alter_ego/alter_ego_service.dart';
import 'package:alter_ego/content/offline_content_repository.dart';
import 'package:alter_ego/models/identity.dart';
import 'package:alter_ego/services/insight_service.dart';
import 'package:flutter/material.dart';

class AdviceScreen extends StatefulWidget {
  const AdviceScreen({super.key});

  @override
  State<AdviceScreen> createState() => _AdviceScreenState();
}

class _AdviceScreenState extends State<AdviceScreen> with SingleTickerProviderStateMixin {
  late Future<List<Map<String, dynamic>>> _councilFuture;
  final _alterEgoService = AlterEgoService();
  final _insightService = InsightService();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _councilFuture = _loadCouncilWithInsights();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      appBar: AppBar(
        title: const Text('Council Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _councilFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final council = snapshot.data!;
            if (council.isEmpty) return const Center(child: Text('Your council is still forming.'));

            return ListView.builder(
              itemCount: council.length,
              itemBuilder: (context, index) {
                final item = council[index];
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
                return FadeTransition(
                  opacity: _animationController.drive(CurveTween(curve: Curves.easeIn)),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.2),
                      end: Offset.zero,
                    ).animate(_animationController),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, ego.name),
                      child: _buildAdviceCard(
                        '${ego.icon} ${ego.name}',
                        advice,
                        _getColorForEgo(ego.name),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }


  Color _getColorForEgo(String egoName) {
    switch (egoName) {
      case 'The Strategist': return Colors.blue.withValues(alpha:0.3);
      case 'The Rebel': return Colors.red.withValues(alpha:0.3);
      case 'The Caretaker': return Colors.green.withValues(alpha:0.3);
      case 'The Shadow': return Colors.purple.withValues(alpha:0.3);
      case 'The Achiever': return Colors.orange.withValues(alpha:0.3);
      case 'The Romantic': return Colors.pink.withValues(alpha:0.3);
      case 'The Protector': return Colors.teal.withValues(alpha:0.3);
      case 'The Analyst': return Colors.indigo.withValues(alpha:0.3);
      case 'The Escapist': return Colors.blueGrey.withValues(alpha:0.3);
      default: return Colors.grey.withValues(alpha:0.3);
    }
  }

  Widget _buildAdviceCard(String egoName, String advice, Color color) {
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              egoName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              advice,
              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
