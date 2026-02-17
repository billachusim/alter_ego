import 'dart:async';

import 'package:alter_ego/advice_screen.dart';
import 'package:alter_ego/alter_ego.dart';
import 'package:alter_ego/alter_ego_service.dart';
import 'package:alter_ego/content/offline_content_repository.dart';
import 'package:alter_ego/history_screen.dart';
import 'package:alter_ego/inner_simulation_screen.dart';
import 'package:alter_ego/models/identity.dart';
import 'package:alter_ego/onboarding_screen.dart';
import 'package:alter_ego/paywall_screen.dart';
import 'package:alter_ego/question_screen.dart';
import 'package:alter_ego/services/app_settings_service.dart';
import 'package:alter_ego/services/monetization_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettingsService();
  final hasOnboarded = await settings.hasOnboarded();
  await MonetizationService.instance.init();
  runApp(AlterEgoApp(hasOnboarded: hasOnboarded));
}

class AlterEgoApp extends StatelessWidget {
  final bool hasOnboarded;
  const AlterEgoApp({super.key, required this.hasOnboarded});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AlterEgo',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF101217)),
      home: hasOnboarded ? const HomePage() : const OnboardingScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _alterEgoService = AlterEgoService();
  final _settings = AppSettingsService();
  final _monetization = MonetizationService.instance;
  StreamSubscription<void>? _sub;

  Future<List<AlterEgo>>? _alterEgosFuture;
  String? _nickname;

  @override
  void initState() {
    super.initState();
    _loadData();
    _sub = _monetization.changes.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final nickname = await _settings.nickname();
    final egos = _alterEgoService.loadAlterEgos();
    setState(() {
      _nickname = nickname;
      _alterEgosFuture = egos;
    });
  }

  Future<bool> _ensurePremium() async {
    if (_monetization.isPremium) return true;
    final unlocked = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const PaywallScreen()));
    return unlocked == true || _monetization.isPremium;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_monetization.isPremium ? 'Alter Ego Premium' : 'Alter Ego Free'),
        actions: [
          if (!_monetization.isPremium)
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen())),
              child: const Text('Go Premium'),
            ),
        ],
      ),
      body: SafeArea(
        child: _alterEgosFuture == null
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<List<AlterEgo>>(
                future: _alterEgosFuture,
                builder: (context, snapshot) {
                  final egos = snapshot.data ?? [];
                  egos.sort((a, b) => b.leaning.compareTo(a.leaning));
                  final visibleCount = _monetization.applyIdentityLimit(egos.length);
                  final visibleEgos = egos.take(visibleCount).toList();
                  final dominant = visibleEgos.isNotEmpty ? visibleEgos.first : null;

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Hey, ${_nickname ?? 'friend'}.', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        const Text('Who is really in control today?', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 20),
                        if (dominant != null)
                          Card(
                            color: Colors.white10,
                            child: ListTile(
                              title: Text('${dominant.icon} ${dominant.name}'),
                              subtitle: Text(_quickAdvice(dominant.name)),
                            ),
                          ),
                        if (visibleEgos.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: visibleEgos
                                .map((e) => Chip(label: Text('${e.name} ${(e.leaning * 100).round()}%')))
                                .toList(),
                          ),
                        if (!_monetization.isPremium)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text('Free tier shows top 3 voices. Upgrade for full identity map.', style: TextStyle(color: Colors.amber)),
                          ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestionScreen()));
                            _loadData();
                          },
                          child: const Text('Run Daily Check-in'),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            if (!_monetization.canAccess(PremiumFeature.deepCouncilSimulation) && !await _ensurePremium()) {
                              return;
                            }
                            if (!mounted) return;
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const InnerSimulationScreen()));
                          },
                          child: Text(_monetization.isPremium ? 'Run Council Simulation' : 'Run Council Simulation (Premium)'),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdviceScreen())),
                              icon: const Icon(Icons.forum),
                              label: const Text('Council Replies'),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                              icon: const Icon(Icons.show_chart),
                              label: Text(_monetization.isPremium ? 'Identity Trends' : 'Identity Trends (Limited)'),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _quickAdvice(String egoName) {
    final id = identityIdFromAny(egoName) ?? IdentityId.shadow;
    return OfflineContentRepository.pickReply(
      identity: id,
      situationType: 'decision',
      intensity: 'low',
      seed: DateTime.now().weekday,
    );
  }
}
