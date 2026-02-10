import 'package:alter_ego/alter_ego.dart';
import 'package:alter_ego/alter_ego_service.dart';
import 'package:alter_ego/question.dart';
import 'package:flutter/material.dart';

class AlterEgoScreen extends StatefulWidget {
  final List<Answer> answers;

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

  Future<List<AlterEgo>> _calculateAndSaveAlterEgos(List<Answer> answers) async {
    final existingEgos = await _alterEgoService.loadAlterEgos();
    final newEgos = _calculateAlterEgos(answers, existingEgos);
    await _alterEgoService.saveAlterEgos(newEgos);
    return newEgos;
  }

  List<AlterEgo> _calculateAlterEgos(List<Answer> answers, List<AlterEgo> existingEgos) {
    Map<String, double> scores = existingEgos.isNotEmpty
        ? {for (var ego in existingEgos) ego.name: ego.leaning}
        : {
            'The Strategist': 0.25,
            'The Rebel': 0.25,
            'The Caretaker': 0.25,
            'The Shadow': 0.25,
          };
    
    // Apply scores from each answer
    for (final answer in answers) {
      for (final score in answer.scores.entries) {
        if (scores.containsKey(score.key)) {
          scores[score.key] = scores[score.key]! + score.value;
        }
      }
    }

    // Ensure no score is negative
    scores.updateAll((key, value) => value < 0 ? 0 : value);

    // Normalize scores to sum to 1
    final totalScore = scores.values.reduce((a, b) => a + b);
    if (totalScore == 0) return existingEgos; // Avoid division by zero
    
    final normalizedScores = scores.map((key, value) => MapEntry(key, value / totalScore));

    // Create a map of existing egos for easy lookup
    final egoDetails = { for (var ego in existingEgos) ego.name : ego };
    final defaultDetails = {
       'The Strategist': {'description': 'plans, thinks ahead, cautious', 'icon': '🜂'},
       'The Rebel': {'description': 'hates rules, impulsive, emotional', 'icon': '🜁'},
       'The Caretaker': {'description': 'empathetic, self-sacrificing', 'icon': '🜄'},
       'The Shadow': {'description': 'withdrawn, observant, critical', 'icon': '🜃'},
    };

    return normalizedScores.entries.map((entry) {
      final detail = egoDetails[entry.key] ?? AlterEgo(name: entry.key, description: defaultDetails[entry.key]!['description']!, icon: defaultDetails[entry.key]!['icon']!, leaning: 0);
      return AlterEgo(
        name: entry.key,
        description: detail.description,
        icon: detail.icon,
        leaning: entry.value,
      );
    }).toList();
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
          egos.sort((a,b) => b.leaning.compareTo(a.leaning)); // Sort by leaning

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      return _voiceCard(ego);
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

  /////////////////////////////////////////////////////////////

  Widget _voiceCard(AlterEgo ego) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha:.04),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${ego.icon}  ${ego.name.toUpperCase()}",
            style: const TextStyle(
              letterSpacing: 1.5,
              fontSize: 13,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 12),
          Text((ego.name),
            style: const TextStyle(
              fontSize: 18,
              height: 1.5,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 12),
          Text((ego.description),
            style: const TextStyle(
              fontSize: 18,
              height: 1.5,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 12),
          Text('${(ego.leaning * 100).toInt()}% ',
            style: const TextStyle(
              fontSize: 18,
              height: 1.5,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
