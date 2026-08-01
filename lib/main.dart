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
import 'package:alter_ego/services/notification_service.dart';
import 'package:alter_ego/settings_screen.dart';
import 'package:alter_ego/services/share_service.dart';
import 'package:alter_ego/widgets/shareable_identity_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettingsService();
  final hasOnboarded = await settings.hasOnboarded();
  await MonetizationService.instance.init();
  await NotificationService.instance.init();
  await NotificationService.instance.syncNotifications();
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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF101217),
        cardTheme: CardThemeData(
          color: Colors.white.withAlpha(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
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
  final _alterEgoService = AlterEgoService();
  final _settings = AppSettingsService();
  final _monetization = MonetizationService.instance;
  final _shareKey = GlobalKey();
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
      body: FutureBuilder<List<AlterEgo>>(
        future: _alterEgosFuture,
        builder: (context, snapshot) {
          final egos = snapshot.data ?? [];
          egos.sort((a, b) => b.leaning.compareTo(a.leaning));
          final visibleCount = _monetization.applyIdentityLimit(egos.length);
          final visibleEgos = egos.take(visibleCount).toList();
          final dominant = visibleEgos.isNotEmpty ? visibleEgos.first : null;

          return Stack(
            children: [
              _buildDynamicBackground(dominant),
              Positioned(
                top: -2000,
                left: 0,
                child: RepaintBoundary(
                  key: _shareKey,
                  child: ShareableIdentityCard(egos: visibleEgos, nickname: _nickname ?? 'friend'),
                ),
              ),
              SafeArea(
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        if (egos.isNotEmpty) _buildRadarChart(egos),
                        const SizedBox(height: 24),
                        _buildPrivacyBadge(),
                        const SizedBox(height: 24),
                        if (dominant != null) _buildDominantEgoCard(dominant, visibleEgos),
                        const SizedBox(height: 20),
                        _buildActionButtons(),
                        const SizedBox(height: 30),
                        if (egos.isNotEmpty) _buildBalanceVisualization(context, egos),
                        const SizedBox(height: 30),
                        _buildSecondaryActions(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hey, ${_nickname ?? 'friend'}.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Text('Who is really in control today?', style: TextStyle(color: Colors.white70)),
          ],
        ),
        if (!_monetization.isPremium)
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen())),
            icon: const Icon(Icons.stars, color: Colors.amber),
          )
        else
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaywallScreen())),
            icon: const Icon(Icons.verified_user, color: Colors.blueAccent),
          ),
      ],
    );
  }

  Widget _buildRadarChart(List<AlterEgo> egos) {
    // Only show if we have enough identities for a radar
    if (egos.length < 3) return const SizedBox();

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.circle,
          radarBorderData: const BorderSide(color: Colors.white10),
          gridBorderData: const BorderSide(color: Colors.white10),
          tickBorderData: const BorderSide(color: Colors.transparent),
          ticksTextStyle: const TextStyle(color: Colors.transparent),
          titlePositionPercentageOffset: 0.2,
          titleTextStyle: const TextStyle(color: Colors.white54, fontSize: 10),
          getTitle: (index, angle) {
            if (index >= egos.length) return const RadarChartTitle(text: '');
            return RadarChartTitle(text: egos[index].name.split(' ').last);
          },
          dataSets: [
            RadarDataSet(
              fillColor: _getColorForEgo(egos.first.name).withAlpha(100),
              borderColor: _getColorForEgo(egos.first.name),
              entryRadius: 3,
              dataEntries: egos.map((e) => RadarEntry(value: e.leaning * 100)).toList(),
            ),
          ],
        ),
      ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildPrivacyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withAlpha(20),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.greenAccent.withAlpha(40)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 14, color: Colors.greenAccent),
          SizedBox(width: 8),
          Text('Zero-Cloud Evaluation: Secure & Local',
              style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildDominantEgoCard(AlterEgo dominant, List<AlterEgo> allVisible) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(dominant.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dominant.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(_quickAdvice(dominant.name),
                      style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                ShareService.captureAndShare(
                  context,
                  _shareKey,
                  text: 'My current dominant Alter Ego is ${dominant.name}.',
                  subject: 'My Alter Ego Identity',
                );
              },
              icon: const Icon(Icons.share, size: 20, color: Colors.white54),
            ),
          ],
        ),
      ),
    ).animate().slideX(begin: 0.1);
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestionScreen()));
            _loadData();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withAlpha(20),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined, size: 18),
              SizedBox(width: 12),
              Text('Daily Check-in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () async {
            if (!_monetization.canAccess(PremiumFeature.deepCouncilSimulation) && !await _ensurePremium()) {
              return;
            }
            if (!mounted) return;
            Navigator.push(context, MaterialPageRoute(builder: (_) => const InnerSimulationScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent.withAlpha(50),
            foregroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.groups_outlined, size: 18),
              const SizedBox(width: 12),
              Text(_monetization.isPremium ? 'Consult Council' : 'Consult Council (Premium)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryActions() {
    return Row(
      children: [
        Expanded(
          child: _secondaryButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdviceScreen())),
            icon: Icons.list_alt_outlined,
            label: 'Ranking',
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _secondaryButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
            icon: Icons.auto_graph_outlined,
            label: 'Evolution',
            color: Colors.purpleAccent,
          ),
        ),
        const SizedBox(width: 16),
        _secondaryButtonIcon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          icon: Icons.settings,
          color: Colors.white54,
        ),
      ],
    );
  }

  Widget _secondaryButtonIcon({required VoidCallback onPressed, required IconData icon, required Color color}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withAlpha(100)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Icon(icon, size: 18),
    );
  }

  Widget _secondaryButton({required VoidCallback onPressed, required IconData icon, required String label, required Color color}) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withAlpha(100)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildDynamicBackground(AlterEgo? dominant) {
    final color = dominant != null ? _getColorForEgo(dominant.name).withAlpha(40) : Colors.transparent;
    return AnimatedContainer(
      duration: 1.seconds,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.5,
          colors: [color, const Color(0xFF101217)],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Alter Ego Balance", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          height: 60,
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(10),
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
    );
  }

  Color _getColorForEgo(String egoName) {
    switch (egoName) {
      case 'The Strategist': return Colors.blue;
      case 'The Rebel': return Colors.red;
      case 'The Caretaker': return Colors.green;
      case 'The Shadow': return Colors.purple;
      case 'The Achiever': return Colors.orange;
      case 'The Romantic': return Colors.pink;
      case 'The Protector': return Colors.teal;
      case 'The Analyst': return Colors.indigo;
      case 'The Escapist': return Colors.blueGrey;
      default: return Colors.grey;
    }
  }
}
