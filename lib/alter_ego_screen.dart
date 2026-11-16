import 'package:alter_ego/alter_ego.dart';
import 'package:alter_ego/alter_ego_service.dart';
import 'package:alter_ego/content/offline_content_repository.dart';
import 'package:alter_ego/main.dart';
import 'package:alter_ego/models/identity.dart';
import 'package:alter_ego/paywall_screen.dart';
import 'package:alter_ego/question.dart';
import 'package:alter_ego/services/monetization_service.dart';
import 'package:alter_ego/services/review_service.dart';
import 'package:alter_ego/services/app_settings_service.dart';
import 'package:alter_ego/services/share_service.dart';
import 'package:alter_ego/widgets/shareable_identity_card.dart';
import 'package:alter_ego/services/game_service.dart';
import 'package:alter_ego/widgets/mystic_background.dart';
import 'package:alter_ego/widgets/reward_overlay.dart';
import 'package:alter_ego/widgets/sigil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AlterEgoScreen extends StatefulWidget {
  final List<Answer> answers;

  const AlterEgoScreen({super.key, required this.answers});

  @override
  State<AlterEgoScreen> createState() => _AlterEgoScreenState();
}

class _AlterEgoScreenState extends State<AlterEgoScreen> {
  late Future<List<AlterEgo>> _alterEgosFuture;
  final _alterEgoService = AlterEgoService();
  final _monetization = MonetizationService.instance;
  final _shareKey = GlobalKey();
  String _nickname = 'friend';

  @override
  void initState() {
    super.initState();
    _alterEgosFuture = _calculateAndSaveAlterEgos(widget.answers);
    _loadNickname();
  }

  Future<void> _loadNickname() async {
    final n = await AppSettingsService().nickname();
    if (n != null) setState(() => _nickname = n);
  }

  Future<List<AlterEgo>> _calculateAndSaveAlterEgos(List<Answer> answers) async {
    final existingEgos = await _alterEgoService.loadAlterEgos();
    final newEgos = _calculateAlterEgos(answers, existingEgos);
    await _alterEgoService.saveAlterEgos(newEgos);
    
    // Check for Review
    final settings = AppSettingsService();
    await settings.incrementCheckInCount();
    final count = await settings.checkInCount();
    ReviewService.maybePromptAfterCheckIn(count);

    final reward = await GameService.instance.recordCheckIn();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final top = (newEgos.toList()..sort((a, b) => b.leaning.compareTo(a.leaning))).first;
      RewardOverlay.show(context, reward, color: _colorFor(identityIdFromAny(top.name)), title: 'Check-in complete');
    });

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

  Future<void> _shareIdentity(List<AlterEgo> egos) async {
    await ShareService.captureAndShare(
      context,
      _shareKey,
      text: 'My mind is currently mapping into ${egos.first.name}. 100% private self-discovery.',
      subject: 'My Alter Ego Identity',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D12),
      appBar: AppBar(title: const Text('Your Voices Today'), backgroundColor: Colors.transparent, elevation: 0),
      body: FutureBuilder<List<AlterEgo>>(
        future: _alterEgosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final egos = (snapshot.data ?? [])..sort((a, b) => b.leaning.compareTo(a.leaning));
          final visible = egos.take(_monetization.applyIdentityLimit(egos.length)).toList();

          return Stack(
            children: [
              Positioned.fill(child: MysticBackground(aura: visible.isEmpty ? const Color(0xff6C5CE7) : _colorFor(identityIdFromAny(visible.first.name)))),
              // "Off-Stage Paint" to avoid debugNeedsPaint errors
              Positioned(
                top: -2000,
                left: 0,
                child: RepaintBoundary(
                  key: _shareKey,
                  child: ShareableIdentityCard(egos: visible, nickname: _nickname),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('These are your active voices today.', style: TextStyle(fontSize: 17, color: Colors.white70)),
                    if (!_monetization.isPremium)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Free tier: top 3 identities shown. Premium unlocks full map + shadow analysis.', style: TextStyle(color: Colors.amber)),
                      ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: visible.length,
                        itemBuilder: (context, index) => _voiceCard(visible[index])
                            .animate()
                            .fadeIn(delay: (250 + 180 * index).ms, duration: 500.ms)
                            .slideY(begin: .25, curve: Curves.easeOutBack),
                      ),
                    ),
                    if (!_monetization.isPremium)
                      OutlinedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen())),
                        child: const Text('Unlock Premium Insights'),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _shareIdentity(visible),
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text('Share My Identity'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage())),
                            child: const Text('Continue'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
          Row(
            children: [
              Sigil(glyph: ego.icon, color: _colorFor(id), size: 44),
              const SizedBox(width: 12),
              Expanded(child: Text(ego.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
            ],
          ),
          const SizedBox(height: 8),
          Text(profile.description),
          const SizedBox(height: 8),
          if (_monetization.canAccess(PremiumFeature.shadowAnalysis)) ...[
            Text('Shadow pattern: ${profile.shadowPattern}', style: const TextStyle(color: Colors.white70)),
            Text('Growth cue: ${profile.growthCue}', style: const TextStyle(color: Colors.white70)),
          ] else
            const Text('Shadow analysis is Premium.', style: TextStyle(color: Colors.amber)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ego.leaning.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(_colorFor(id)),
            ),
          ),
          const SizedBox(height: 4),
          Text('${(ego.leaning * 100).toStringAsFixed(1)}% of your energy', style: const TextStyle(fontSize: 12, color: Colors.white54)),
        ],
      ),
    );
  }

  Color _colorFor(IdentityId? id) {
    return switch (id) {
      IdentityId.strategist => Colors.blue,
      IdentityId.rebel => Colors.red,
      IdentityId.caretaker => Colors.green,
      IdentityId.achiever => Colors.orange,
      IdentityId.romantic => Colors.pink,
      IdentityId.protector => Colors.teal,
      IdentityId.analyst => Colors.indigo,
      IdentityId.escapist => Colors.blueGrey,
      IdentityId.shadow => Colors.purple,
      null => const Color(0xff6C5CE7),
    };
  }
}
