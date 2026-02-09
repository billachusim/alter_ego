import 'package:alter_ego/advice_screen.dart';
import 'package:alter_ego/alter_ego.dart';
import 'package:alter_ego/alter_ego_service.dart';
import 'package:alter_ego/onboarding_screen.dart';
import 'package:alter_ego/question_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasOnboarded = prefs.getBool('hasOnboarded') ?? false;
  runApp(AlterEgoApp(hasOnboarded: hasOnboarded));
}

class AlterEgoApp extends StatelessWidget {
  final bool hasOnboarded;
  const AlterEgoApp({super.key, required this.hasOnboarded});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlterEgo',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        primaryColor: Colors.white,
        colorScheme: const ColorScheme.dark(primary: Colors.white, secondary: Colors.blueAccent),
      ),
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
  late Future<List<AlterEgo>> _alterEgosFuture;
  final _alterEgoService = AlterEgoService();
  String? _nickname;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nickname = prefs.getString('nickname');
      _alterEgosFuture = _alterEgoService.loadAlterEgos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<AlterEgo>>(
          future: _alterEgosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _nickname == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final egos = snapshot.data ?? [];
            final dominantEgo = egos.isNotEmpty ? egos.reduce((a, b) => a.leaning > b.leaning ? a : b) : null;

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hey, ${_nickname ?? 'friend'}.",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  // Section 1: Dominant Alter Ego
                  Text(
                    "Today's Dominant Alter Ego",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dominantEgo != null ? "${dominantEgo.icon} ${dominantEgo.name}" : "Unknown",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),

                  // Section 2: Quick Advice (could be linked to dominant ego)
                  Text(
                    "Quick Advice",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dominantEgo != null ? _getAdviceForEgo(dominantEgo.name) : "Answer some questions to get advice.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 32),

                  // Section 3: Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const QuestionScreen()),
                          );
                          _loadData(); // Refresh data after check-in
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white12,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: const Text("Check-in"),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: egos.isNotEmpty ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdviceScreen()),
                          );
                        } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.3),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: const Text("Get Advice"),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Section 4: Alter Ego Balance Visualization
                  if (egos.isNotEmpty)
                    _buildBalanceVisualization(context, egos),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getAdviceForEgo(String egoName) {
    switch (egoName) {
      case 'The Strategist': return "Wait. Think about the consequences.";
      case 'The Rebel': return "Do it. You're tired of playing safe.";
      case 'The Caretaker': return "How will this affect people you care about?";
      case 'The Shadow': return "Observe for now. Information is power.";
      default: return "Embrace the mystery within.";
    }
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
                    child: Container(
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
      case 'The Strategist': return Colors.blue.withOpacity(0.8);
      case 'The Rebel': return Colors.red.withOpacity(0.8);
      case 'The Caretaker': return Colors.green.withOpacity(0.8);
      case 'The Shadow': return Colors.purple.withOpacity(0.8);
      default: return Colors.grey;
    }
  }
}
