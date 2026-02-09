import 'package:alter_ego/alter_ego.dart';
import 'package:alter_ego/alter_ego_service.dart';
import 'package:flutter/material.dart';

class AlterEgoScreen extends StatefulWidget {
  final List<int> answers;

  const AlterEgoScreen({super.key, required this.answers});

  @override
  State<AlterEgoScreen> createState() => _AlterEgoScreenState();
}

class _AlterEgoScreenState extends State<AlterEgoScreen> {
  late Future<List<AlterEgo>> _alterEgosFuture;
  final _alterEgoService = AlterEgoService();

  @override
  void initState() {
    super.initState();
    _alterEgosFuture = _calculateAndSaveAlterEgos(widget.answers);
  }

  Future<List<AlterEgo>> _calculateAndSaveAlterEgos(List<int> answers) async {
    final existingEgos = await _alterEgoService.loadAlterEgos();
    final newEgos = _calculateAlterEgos(answers, existingEgos);
    await _alterEgoService.saveAlterEgos(newEgos);
    return newEgos;
  }

  List<AlterEgo> _calculateAlterEgos(List<int> answers, List<AlterEgo> existingEgos) {
    Map<String, double> scores = existingEgos.isNotEmpty
        ? {for (var ego in existingEgos) ego.name: ego.leaning}
        : {
            'The Strategist': 0.25,
            'The Rebel': 0.25,
            'The Caretaker': 0.25,
            'The Shadow': 0.25,
          };

    // Simplified logic: Each answer index corresponds to an alter ego.
    // This is a placeholder for a more sophisticated scoring model.
    // A real implementation would have a more complex weighting and decay system.
    if (answers[0] == 0) scores['The Shadow'] = scores['The Shadow']! + 0.05;
    if (answers[0] == 1) scores['The Rebel'] = scores['The Rebel']! + 0.05;
    if (answers[0] == 2) scores['The Caretaker'] = scores['The Caretaker']! + 0.05;

    if (answers[1] == 0) scores['The Strategist'] = scores['The Strategist']! + 0.05;
    if (answers[1] == 1) scores['The Rebel'] = scores['The Rebel']! + 0.05;

    if (answers[2] == 0) scores['The Strategist'] = scores['The Strategist']! + 0.05;
    if (answers[2] == 1) scores['The Rebel'] = scores['The Rebel']! + 0.05;
    if (answers[2] == 2) scores['The Caretaker'] = scores['The Caretaker']! + 0.05;

    // Normalize scores to sum to 1
    final totalScore = scores.values.reduce((a, b) => a + b);
    final normalizedScores = scores.map((key, value) => MapEntry(key, value / totalScore));

    return [
      AlterEgo(name: 'The Strategist', description: 'plans, thinks ahead, cautious', icon: '🜂', leaning: normalizedScores['The Strategist']!),
      AlterEgo(name: 'The Rebel', description: 'hates rules, impulsive, emotional', icon: '🜁', leaning: normalizedScores['The Rebel']!),
      AlterEgo(name: 'The Caretaker', description: 'empathetic, self-sacrificing', icon: '🜄', leaning: normalizedScores['The Caretaker']!),
      AlterEgo(name: 'The Shadow', description: 'withdrawn, observant, critical', icon: '🜃', leaning: normalizedScores['The Shadow']!),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Evolving Alter Egos'),
      ),
      body: FutureBuilder<List<AlterEgo>>(
        future: _alterEgosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error calculating your alter egos.'));
          }
          final egos = snapshot.data ?? [];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "These are not labels.\nThey are tendencies I see emerging.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: egos.length,
                    itemBuilder: (context, index) {
                      final ego = egos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: Text(ego.icon, style: const TextStyle(fontSize: 24)),
                          title: Text(ego.name),
                          subtitle: Text(ego.description),
                          trailing: Text('${(ego.leaning * 100).toInt()}% '),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    "I'm not sure yet.\nI'll learn as you live.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
