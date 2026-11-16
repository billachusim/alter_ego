import 'dart:math';

import 'package:alter_ego/content/omens.dart';
import 'package:alter_ego/models/identity.dart';
import 'package:alter_ego/services/game_service.dart';
import 'package:alter_ego/widgets/reward_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Today's omen: a face-down card that flips over when tapped.
class OmenCard extends StatefulWidget {
  final Color color;
  final IdentityId? dominant;
  final bool alreadyRevealed;
  final VoidCallback? onRevealed;
  const OmenCard({super.key, required this.color, this.dominant, this.alreadyRevealed = false, this.onRevealed});

  @override
  State<OmenCard> createState() => _OmenCardState();
}

class _OmenCardState extends State<OmenCard> with SingleTickerProviderStateMixin {
  late final AnimationController _flip = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late bool _revealed = widget.alreadyRevealed;

  @override
  void initState() {
    super.initState();
    if (_revealed) _flip.value = 1;
  }

  @override
  void didUpdateWidget(covariant OmenCard old) {
    super.didUpdateWidget(old);
    if (widget.alreadyRevealed && !_revealed) {
      _revealed = true;
      _flip.value = 1;
    }
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  Future<void> _reveal() async {
    if (_revealed) return;
    HapticFeedback.heavyImpact();
    setState(() => _revealed = true);
    await _flip.forward();
    final reward = await GameService.instance.revealOmen();
    if (reward != null && mounted) {
      RewardOverlay.show(context, reward, color: widget.color, title: 'Omen received');
    }
    widget.onRevealed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final omen = Omens.today();
    return GestureDetector(
      onTap: _reveal,
      child: AnimatedBuilder(
        animation: _flip,
        builder: (context, _) {
          final angle = _flip.value * pi;
          final showFront = angle > pi / 2;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: showFront
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _front(omen),
                  )
                : _back(),
          );
        },
      ),
    );
  }

  Widget _frame({required Widget child}) => Container(
        height: 190,
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [widget.color.withAlpha(70), const Color(0xff1B1530), const Color(0xff0E0B1A)],
          ),
          border: Border.all(color: widget.color.withAlpha(120)),
          boxShadow: [BoxShadow(color: widget.color.withAlpha(60), blurRadius: 30)],
        ),
        child: child,
      );

  Widget _back() => _frame(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text('✧ ☽ ✧', style: TextStyle(fontSize: 46, color: widget.color.withAlpha(200)))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(.95, .95), end: const Offset(1.05, 1.05), duration: 1600.ms)
                .then()
                .shimmer(duration: 1800.ms, color: Colors.white54),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Text('TAP TO REVEAL TODAY\'S OMEN', style: TextStyle(letterSpacing: 2.5, fontSize: 11, color: Colors.white60, fontWeight: FontWeight.bold)),
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Text('DAILY OMEN', style: TextStyle(letterSpacing: 2.5, fontSize: 10, color: Colors.white38)),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Text('+${GameService.omenXp} ✦', style: TextStyle(fontSize: 11, color: widget.color, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

  Widget _front(Omen omen) => _frame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(omen.symbol, style: TextStyle(fontSize: 30, color: widget.color)),
                const SizedBox(width: 10),
                Text(omen.name.toUpperCase(), style: const TextStyle(letterSpacing: 3, fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 10),
            Text(omen.message, style: const TextStyle(fontSize: 15, height: 1.35, color: Colors.white)),
            const Spacer(),
            Text('Ritual: ${omen.ritual}', style: const TextStyle(fontSize: 12, height: 1.3, color: Colors.white70)),
            const SizedBox(height: 4),
            Text(Omens.whisper(widget.dominant), style: TextStyle(fontSize: 12, color: widget.color, fontStyle: FontStyle.italic)),
          ],
        ),
      );
}
