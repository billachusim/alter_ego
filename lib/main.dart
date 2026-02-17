import 'package:alter_ego/advice_screen.dart';
import 'package:alter_ego/alter_ego.dart';
import 'package:alter_ego/alter_ego_service.dart';
import 'package:alter_ego/content/offline_content_repository.dart';
import 'package:alter_ego/history_screen.dart';
import 'package:alter_ego/inner_simulation_screen.dart';
import 'package:alter_ego/models/identity.dart';
import 'package:alter_ego/onboarding_screen.dart';
import 'package:alter_ego/question_screen.dart';
import 'package:alter_ego/services/app_settings_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettingsService();
  final hasOnboarded = await settings.hasOnboarded();
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
  Future<List<AlterEgo>>? _alterEgosFuture;
  String? _nickname;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final nickname = await _settings.nickname();
    final egos = _alterEgoService.loadAlterEgos();
    setState(() {
      _nickname = nickname;
      _alterEgosFuture = egos;
    });
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
                  final top3 = egos.take(3).toList();
                  final dominant = top3.isNotEmpty ? top3.first : null;

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
                        if (top3.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: top3
                                .map((e) => Chip(label: Text('${e.name} ${(e.leaning * 100).round()}%')))
                                .toList(),
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
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InnerSimulationScreen())),
                          child: const Text('Run Council Simulation'),
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
                              label: const Text('Identity Trends'),
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
