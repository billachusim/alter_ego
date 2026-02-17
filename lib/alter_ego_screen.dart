import 'package:alter_ego/alter_ego.dart';
import 'package:alter_ego/alter_ego_service.dart';
import 'package:alter_ego/content/offline_content_repository.dart';
import 'package:alter_ego/models/identity.dart';
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
    final scores = {
      for (final profile in OfflineContentRepository.profiles)
        profile.label: (1 / OfflineContentRepository.profiles.length)
    };

    for (final ego in existingEgos) {
      scores[ego.name] = ego.leaning;
    }

    for (final answer in answers) {
      for (final score in answer.scores.entries) {
        final label = identityStorageLabel(score.key);
        scores[label] = (scores[label] ?? 0) + score.value;
      }
    }

    scores.updateAll((key, value) => value < 0 ? 0 : value);
    final totalScore = scores.values.reduce((a, b) => a + b);
    final normalized = scores.map((key, value) => MapEntry(key, value / totalScore));

    return normalized.entries.map((entry) {
      final id = identityIdFromAny(entry.key)!;
      final profile = OfflineContentRepository.profilesById[id]!;
      return AlterEgo(
        name: profile.label,
        description: profile.description,
        icon: profile.icon,
        leaning: entry.value,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Evolving Alter Egos')),
      body: FutureBuilder<List<AlterEgo>>(
        future: _alterEgosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final egos = (snapshot.data ?? [])..sort((a, b) => b.leaning.compareTo(a.leaning));
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('These are your active voices today.', style: TextStyle(fontSize: 17, color: Colors.white70)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: egos.length,
                    itemBuilder: (context, index) => _voiceCard(egos[index]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Continue'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _voiceCard(AlterEgo ego) {
    final id = identityIdFromAny(ego.name)!;
    final profile = OfflineContentRepository.profilesById[id]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: .04),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${ego.icon} ${ego.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(profile.description),
          const SizedBox(height: 8),
          Text('Shadow pattern: ${profile.shadowPattern}', style: const TextStyle(color: Colors.white70)),
          Text('Growth cue: ${profile.growthCue}', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text('${(ego.leaning * 100).toStringAsFixed(1)}%'),
        ],
      ),
    );
  }
}
