import 'package:alter_ego/content/offline_content_repository.dart';
import 'package:alter_ego/ego_conflict.dart';
import 'package:alter_ego/ego_conflict_engine.dart';
import 'package:alter_ego/models/identity.dart';
import 'package:alter_ego/paywall_screen.dart';
import 'package:alter_ego/services/monetization_service.dart';
import 'package:alter_ego/whisper_engine.dart';
import 'package:flutter/material.dart';

class InnerSimulationScreen extends StatefulWidget {
  const InnerSimulationScreen({super.key});

  @override
  State<InnerSimulationScreen> createState() => _InnerSimulationScreenState();
}

class _InnerSimulationScreenState extends State<InnerSimulationScreen> {
  final _controller = TextEditingController();
  final _monetization = MonetizationService.instance;
  bool _isSimulating = false;
  bool _voicesEnabled = true;
  List<EgoConflict>? _conflicts;

  Future<void> _simulate() async {
    if (_controller.text.trim().isEmpty || _isSimulating) return;

    if (!_monetization.canAccess(PremiumFeature.deepCouncilSimulation)) {
      final unlocked = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
      if (unlocked != true && !_monetization.isPremium) {
        return;
      }
    }

    setState(() => _isSimulating = true);

    final generated = EgoConflictEngine.generate(_controller.text.trim());
    final visible = generated.take(_monetization.applyCouncilDepthLimit(generated.length)).toList();

    setState(() {
      _conflicts = visible;
      _isSimulating = false;
    });

    if (_voicesEnabled && WhisperEngine.isConfigured) {
      await WhisperEngine.preloadConflicts(visible);
      await WhisperEngine.speakConflicts(visible);
    } else if (_voicesEnabled && mounted && !WhisperEngine.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice playback unavailable: missing ELEVEN_LABS_API_KEY.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inner Council')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Confess a thought... a fear... a decision.',
                border: OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              value: _voicesEnabled,
              title: const Text('Enable ElevenLabs voice'),
              onChanged: (v) => setState(() => _voicesEnabled = v),
            ),
            if (!_monetization.isPremium)
              const Text('Deep multi-voice simulation is Premium.', style: TextStyle(color: Colors.amber)),
            ElevatedButton(
              onPressed: _simulate,
              child: Text(_isSimulating ? 'Simulating...' : 'Simulate Council'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: (_conflicts ?? []).map((c) {
                  final profile = OfflineContentRepository.profilesById[c.identity]!;
                  return Card(
                    color: _egoColor(c.identity),
                    child: ListTile(
                      title: Text('${profile.icon} ${profile.label}'),
                      subtitle: Text('${c.message}\n\n${c.rationale}'),
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _egoColor(IdentityId id) {
    return switch (id) {
      IdentityId.strategist => Colors.blue.withValues(alpha: .18),
      IdentityId.rebel => Colors.red.withValues(alpha: .18),
      IdentityId.caretaker => Colors.green.withValues(alpha: .18),
      IdentityId.achiever => Colors.orange.withValues(alpha: .18),
      IdentityId.romantic => Colors.pink.withValues(alpha: .18),
      IdentityId.protector => Colors.teal.withValues(alpha: .18),
      IdentityId.analyst => Colors.indigo.withValues(alpha: .18),
      IdentityId.escapist => Colors.blueGrey.withValues(alpha: .18),
      IdentityId.shadow => Colors.purple.withValues(alpha: .18),
    };
  }
}
