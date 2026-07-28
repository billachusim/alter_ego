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

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Hey, ${_nickname ?? 'friend'}.', style: Theme.of(context).textTheme.headlineSmall),

                        if (!_monetization.isPremium)
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen())),
                            child: const Text('Go Premium'),
                          ),
                        if (_monetization.isPremium)
                          TextButton(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen())),
                            child: const Text('Premium'),
                          ),
                      ],
                    ),
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
                    const SizedBox(height: 10),
                    if (visibleEgos.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        children: visibleEgos
                            .map((e) => Chip(label: Text('${e.name} ${(e.leaning * 100).round()}%')))
                            .toList(),
                      ),
                    const SizedBox(height: 10),
                    if (!_monetization.isPremium)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text('Free tier shows top 3 voices. Upgrade for full identity map.',
                            style: TextStyle(color: Colors.amber)),
                      ),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestionScreen()));
                        _loadData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white12,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: const Text('Daily Check-in'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (!_monetization.canAccess(PremiumFeature.deepCouncilSimulation) &&
                            !await _ensurePremium()) {
                          return;
                        }
                        if (!context.mounted) return;
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const InnerSimulationScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.withAlpha(77),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      child: Text(_monetization.isPremium ? 'Ask Council' : 'Ask Council (Premium)'),
                    ),
                    const SizedBox(height: 40), // Replaced Spacer with a SizedBox for defined spacing
                    if (egos.isNotEmpty) _buildBalanceVisualization(context, egos),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AdviceScreen()),
                            );
                          },
                          icon: const Icon(Icons.replay, size: 16),
                          label: const Text('Ranking'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.amber,
                            side: const BorderSide(color: Colors.amber),
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HistoryScreen()),
                            );
                          },
                          icon: const Icon(Icons.show_chart, size: 16),
                          label: Text(_monetization.isPremium ? 'Evolution' : 'Evolution (Limited)'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.amber,
                            side: const BorderSide(color: Colors.amber),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20), // Added padding at the bottom for better scroll aesthetics
                  ],
                ),
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

  Widget _buildBalanceVisualization(BuildContext context, List<AlterEgo> egos) {
    return Center(
      child: Column(
        children: [
          Text(
            "Alter Ego Balance",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Container(
            height: 100,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: egos.map((ego) {
                return Expanded(
                  flex: (ego.leaning * 100).toInt(),
                  child: Tooltip(
                    message: '${ego.name}: ${(ego.leaning * 100).toInt()}%',
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _getColorForEgo(ego.name),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForEgo(String egoName) {
    switch (egoName) {
      case 'The Strategist': return Colors.blue.withValues(alpha:0.8);
      case 'The Rebel': return Colors.red.withValues(alpha:0.8);
      case 'The Caretaker': return Colors.green.withValues(alpha:0.8);
      case 'The Shadow': return Colors.purple.withValues(alpha:0.8);
      case 'The Achiever': return Colors.orange.withValues(alpha:0.8);
      case 'The Romantic': return Colors.pink.withValues(alpha:0.8);
      case 'The Protector': return Colors.teal.withValues(alpha:0.8);
      case 'The Analyst': return Colors.indigo.withValues(alpha:0.8);
      case 'The Escapist': return Colors.blueGrey.withValues(alpha:0.8);

      default: return Colors.grey;
    }
  }
}
