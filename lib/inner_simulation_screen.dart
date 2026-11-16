import 'package:alter_ego/whisper_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'ego_conflict.dart';
import 'alter_ego_service.dart';
import 'services/app_settings_service.dart';
import 'council/council_engine.dart';
import 'models/identity.dart';

class InnerSimulationScreen extends StatefulWidget {
  const InnerSimulationScreen({super.key});

  @override
  State<InnerSimulationScreen> createState() => _InnerSimulationScreenState();
}

class _InnerSimulationScreenState extends State<InnerSimulationScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _stt = stt.SpeechToText();
  
  bool _isSpeaking = false;
  bool _voicesEnabled = true;
  bool _isListening = false;
  List<EgoConflict>? _conflicts;
  CouncilVerdict? _verdict;
  Map<IdentityId, double> _leanings = const {};
  String? _nickname;
  int _asks = 0;
  bool _isSimulating = false;
  bool _revealed = false;

  final List<String> _prompts = [
    "Should I take the risk?",
    "Why do I feel stuck?",
    "Is this the right path?",
    "Am I being too hard on myself?",
    "What am I missing?",
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadLeanings();
  }

  Future<void> _loadLeanings() async {
    try {
      final egos = await AlterEgoService().loadAlterEgos();
      final map = <IdentityId, double>{};
      for (final e in egos) {
        final id = identityIdFromAny(e.name);
        if (id != null) map[id] = e.leaning.clamp(0.0, 1.0);
      }
      final nick = await AppSettingsService().nickname();
      if (mounted) setState(() { _leanings = map; _nickname = nick; });
    } catch (e) {
      debugPrint('Could not load leanings: $e');
    }
  }

  void _initSpeech() async {
    await _stt.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    WhisperEngine.stop();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _stt.initialize();
      if (available) {
        setState(() => _isListening = true);
        _stt.listen(
          // Recognise on the phone only, so speech never leaves the device.
          listenOptions: stt.SpeechListenOptions(onDevice: true),
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _stt.stop();
    }
  }

  Future<void> _simulate() async {
    if (_isSimulating || _isSpeaking) return;
    if (_controller.text.trim().isEmpty) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isSimulating = true;
      _revealed = false;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final result = CouncilEngine.consult(_controller.text.trim(), leanings: _leanings, nickname: _nickname, salt: _asks++);
      _conflicts = result.voices;
      _verdict = result.verdict;

      final preloadFuture = WhisperEngine.preloadConflicts(_conflicts!);
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isSimulating = false;
        _revealed = true;
      });

      await preloadFuture;
      await Future.delayed(const Duration(milliseconds: 500));

      if (_voicesEnabled) {
        setState(() => _isSpeaking = true);
        await WhisperEngine.speakConflicts(_conflicts!);
        setState(() => _isSpeaking = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Something interrupted the inner voices.")),
        );
      }
      debugPrint("Simulation error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSimulating = false;
          _isSpeaking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xff0B0D12),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xff1B1F2B), Color(0xff0B0D12)],
                  radius: 1.2,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildTopBar(),
                    const SizedBox(height: 40),
                    _buildOrb(),
                    const SizedBox(height: 40),
                    _buildThoughtField(),
                    const SizedBox(height: 16),
                    _buildPromptsStrip(),
                    const SizedBox(height: 16),
                    _buildRunButton(),
                    const SizedBox(height: 30),
                    Expanded(child: _buildVoices()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 8),
        const Text("INNER COUNCIL", style: TextStyle(letterSpacing: 3, color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
        const Spacer(),
        Icon(Icons.graphic_eq, size: 18, color: _voicesEnabled ? Colors.blueAccent : Colors.white24),
        Switch(
          value: _voicesEnabled,
          activeTrackColor: Colors.blueAccent.withAlpha(100),
          activeThumbColor: Colors.blueAccent,
          onChanged: (value) => setState(() => _voicesEnabled = value),
        ),
      ],
    );
  }

  Widget _buildOrb() {
    Color orbColor = Colors.deepPurpleAccent;
    if (_isSimulating) orbColor = Colors.cyanAccent;
    if (_isSpeaking) orbColor = Colors.pinkAccent;

    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [orbColor.withAlpha(200), orbColor]),
        boxShadow: [
          BoxShadow(color: orbColor.withAlpha(100), blurRadius: _isSpeaking ? 80 : 40, spreadRadius: _isSpeaking ? 20 : 5)
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(duration: _isSimulating ? 500.ms : 2.seconds, begin: const Offset(1, 1), end: const Offset(1.15, 1.15), curve: Curves.easeInOut)
        .blur(begin: const Offset(0, 0), end: _isSpeaking ? const Offset(5, 5) : const Offset(0, 0));
  }

  Widget _buildThoughtField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: 2,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "What is on your mind?",
                hintStyle: TextStyle(color: Colors.white24),
              ),
            ),
          ),
          IconButton(
            onPressed: _listen,
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.redAccent : Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptsStrip() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _prompts.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(_prompts[i], style: const TextStyle(fontSize: 12, color: Colors.white70)),
              backgroundColor: Colors.white.withAlpha(10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: () => setState(() => _controller.text = _prompts[i]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRunButton() {
    return GestureDetector(
      onTap: _simulate,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [Color(0xff6C5CE7), Color(0xff8E7CFF)]),
          boxShadow: [BoxShadow(color: const Color(0xff6C5CE7).withAlpha(50), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Center(
          child: Text(
            _isSimulating ? "Consulting Council..." : "Simulate Council",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    ).animate(target: _isSimulating ? 1 : 0).shimmer(duration: 2.seconds);
  }

  Widget _buildVoices() {
    if (_isSimulating) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(height: 16),
            Text("Your minds are debating...", style: TextStyle(color: Colors.white38, letterSpacing: 1)),
          ],
        ),
      );
    }

    if (!_revealed || _conflicts == null) return const SizedBox();

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: _conflicts!.length + (_verdict == null ? 0 : 1),
      padding: const EdgeInsets.only(bottom: 40),
      itemBuilder: (context, i) => i < _conflicts!.length
          ? _conflictBubble(_conflicts![i], i)
          : _verdictCard(_verdict!, i),
    );
  }

  Widget _verdictCard(CouncilVerdict verdict, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0x336C5CE7), Color(0x228E7CFF)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x666C5CE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('COUNCIL VERDICT', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: Color(0xff8E7CFF), fontSize: 11)),
          const SizedBox(height: 12),
          Text(verdict.tension, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.white70)),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.flag_outlined, size: 18, color: Color(0xff8E7CFF)),
              const SizedBox(width: 8),
              Expanded(child: Text(verdict.nextStep, style: const TextStyle(fontSize: 16, height: 1.4, color: Colors.white, fontWeight: FontWeight.w600))),
            ],
          ),
          if (verdict.truth != null) ...[
            const SizedBox(height: 14),
            Text('“${verdict.truth}”', style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xffE0D7FF))),
          ],
          const SizedBox(height: 14),
          Text(verdict.reflection, style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.white54, fontStyle: FontStyle.italic)),
        ],
      ),
    ).animate().fadeIn(delay: (200 * index).ms).slideY(begin: 0.1);
  }

  Widget _conflictBubble(EgoConflict conflict, int index) {
    final color = _egoColor(conflict.identity);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              ),
              const SizedBox(width: 10),
              Text(conflict.identity.name.toUpperCase(), style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold, color: color, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Text(conflict.message, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white)),
          const SizedBox(height: 10),
          Text(conflict.rationale, style: TextStyle(fontSize: 12, color: color.withAlpha(180))),
        ],
      ),
    ).animate().fadeIn(delay: (200 * index).ms).slideY(begin: 0.1);
  }

  Color _egoColor(IdentityId id) {
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
    };
  }
}
