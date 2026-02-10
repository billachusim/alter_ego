import 'package:alter_ego/whisper_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'ego_conflict.dart';
import 'ego_conflict_engine.dart';

class InnerSimulationScreen extends StatefulWidget {
  const InnerSimulationScreen({super.key});

  @override
  State<InnerSimulationScreen> createState() => _InnerSimulationScreenState();
}

class _InnerSimulationScreenState extends State<InnerSimulationScreen>
    with TickerProviderStateMixin {
  final _controller = TextEditingController();
  bool _isSpeaking = false;
  bool _voicesEnabled = false;



  List<EgoConflict>? _conflicts;


  bool _isSimulating = false;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  Future<void> _load() async {
    setState(() {});
  }

  Future<void> _simulate() async {

    if (_isSimulating || _isSpeaking) return;
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isSimulating = true;
      _voicesEnabled = true;
      _revealed = false;
    });

    try {

      await Future.delayed(const Duration(milliseconds: 400));

      _conflicts = EgoConflictEngine.generate(
        _controller.text.trim(),
      );

      final conflictMaps = _conflicts!
          .map((e) => {
        "ego": e.ego,
        "message": e.message,
      })
          .toList();

      /// 🔥 START PRELOADING HERE (while UI still simulating)
      final preloadFuture =
      WhisperEngine.preloadConflicts(conflictMaps);

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isSimulating = false;
        _revealed = true;
      });

      /// Ensure audio is fully ready
      await preloadFuture;

      await Future.delayed(const Duration(milliseconds: 500));

      _isSpeaking = true;

      if (_voicesEnabled) {
        await WhisperEngine.speakConflicts(conflictMaps);
      }

    } catch (e) {

      /// Optional — show user something graceful
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something interrupted the inner voices."),
          ),
        );
      }

      debugPrint("Simulation error: $e");

    } finally {

      _isSpeaking = false;

      if (mounted) {
        setState(() {
          _isSimulating = false;
        });
      }
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0B0D12),
      appBar: AppBar(
        title: const Text('Inner Simulation'),
        actions: [

          Row(
            children: [

              const Icon(Icons.graphic_eq, size: 18),

              Switch(
                value: _voicesEnabled,
                onChanged: (value) {
                  setState(() {
                    _voicesEnabled = value;
                  });
                },
              ),

              const SizedBox(width: 8),
            ],
          ),
        ],
      ),

      body: Stack(
        children: [
          /// ambient gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0xff1B1F2B),
                  Color(0xff0B0D12),
                ],
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

                  const Text(
                    "INNER COUNCIL",
                    style: TextStyle(
                      letterSpacing: 3,
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// breathing orb
                  _buildOrb(),

                  const SizedBox(height: 40),

                  _buildThoughtField(),

                  const SizedBox(height: 25),

                  _buildRunButton(),

                  const SizedBox(height: 30),

                  Expanded(child: _buildVoices()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /////////////////////////////////////////////////////////////

  Widget _buildOrb() {
    return Container(
      height: 130,
      width: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xff6C5CE7),
            Color(0xffA29BFE),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha:.6),
            blurRadius: 60,
            spreadRadius: 10,
          )
        ],
      ),
    )
        .animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    )
        .scale(
      duration: _isSimulating ? 900.ms : 4.seconds,
      begin: const Offset(1, 1),
      end: const Offset(1.12, 1.12),
      curve: Curves.easeInOut,
    );
  }

  /////////////////////////////////////////////////////////////

  Widget _buildThoughtField() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: _controller,
        maxLines: 4,
        style: const TextStyle(fontSize: 16),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Confess a thought... a fear... a decision.",
          hintStyle: TextStyle(color: Colors.white30),
        ),
      ),
    );
  }

  /////////////////////////////////////////////////////////////

  Widget _buildRunButton() {
    return GestureDetector(
      onTap: _simulate,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [
              Color(0xff6C5CE7),
              Color(0xff8E7CFF),
            ],
          ),
        ),
        child: Center(
          child: Text(
            _isSimulating
                ? "Consulting your council..."
                : "Run Inner Simulation",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    )
        .animate(target: _isSimulating ? 1 : 0)
        .shimmer(duration: 2.seconds);
  }

  /////////////////////////////////////////////////////////////

  Widget _buildVoices() {
    if (_isSimulating) {
      return const Center(
        child: Text(
          "Your minds are debating...",
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    if (!_revealed || _conflicts == null) return const SizedBox();

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _conflicts!.length,
      itemBuilder: (context, i) {

        final conflict = _conflicts![i];

        return _conflictBubble(conflict, i);
      },
    );
  }




  Widget _conflictBubble(EgoConflict conflict, int index) {

    final color = _egoColor(conflict.ego);

    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500 + (index * 120)),
      tween: Tween(begin: 40.0, end: 0.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(
            opacity: 1 - (value / 40),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              conflict.ego.toUpperCase(),
              style: const TextStyle(
                letterSpacing: 1.4,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              conflict.message,
              style: const TextStyle(
                fontSize: 17,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _egoColor(String ego) {
    switch (ego) {
      case "Strategist":
        return Colors.blue.withValues(alpha:.15);

      case "Rebel":
        return Colors.red.withValues(alpha:.15);

      case "Shadow":
        return Colors.purple.withValues(alpha:.18);

      case "Caretaker":
        return Colors.green.withValues(alpha:.15);

      default:
        return Colors.white10;
    }
  }


}
