import 'dart:math';

import 'package:alter_ego/services/game_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A burst of particles with the energy gained, streak and any new rank.
class RewardOverlay {
  static Future<void> show(BuildContext context, Reward reward, {required Color color, String title = 'Energy gained'}) async {
    HapticFeedback.mediumImpact();
    final entry = OverlayEntry(builder: (_) => _RewardBurst(reward: reward, color: color, title: title));
    Overlay.of(context).insert(entry);
    await Future.delayed(Duration(milliseconds: reward.rankUp != null ? 3600 : 2300));
    entry.remove();
  }
}

class _RewardBurst extends StatelessWidget {
  final Reward reward;
  final Color color;
  final String title;
  const _RewardBurst({required this.reward, required this.color, required this.title});

  @override
  Widget build(BuildContext context) {
    final rng = Random();
    final rank = reward.rankUp;
    return IgnorePointer(
      child: Material(
        color: Colors.black.withAlpha(rank != null ? 150 : 60),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Particles flying out from the centre.
            for (var i = 0; i < 28; i++)
              _particle(rng, i, i.isEven ? color : Colors.white),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (rank != null) ...[
                  Text(rank.glyph, style: TextStyle(fontSize: 72, color: color))
                      .animate()
                      .scale(begin: const Offset(.2, .2), duration: 700.ms, curve: Curves.elasticOut)
                      .then()
                      .shimmer(duration: 1200.ms, color: Colors.white),
                  const SizedBox(height: 8),
                  const Text('RANK ASCENDED', style: TextStyle(letterSpacing: 4, fontSize: 13, color: Colors.white70, fontWeight: FontWeight.bold))
                      .animate().fadeIn(delay: 300.ms),
                  Text(rank.title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Colors.white))
                      .animate().fadeIn(delay: 450.ms).slideY(begin: .3),
                  const SizedBox(height: 16),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xff15121F).withAlpha(235),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: color.withAlpha(160)),
                    boxShadow: [BoxShadow(color: color.withAlpha(90), blurRadius: 30)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title.toUpperCase(), style: const TextStyle(letterSpacing: 2.5, fontSize: 11, color: Colors.white54)),
                      const SizedBox(height: 4),
                      Text('+${reward.xpGained} ✦', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: color)),
                      if (reward.streakGrew && reward.streak > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          reward.streak == 1 ? '🔥 Streak started' : '🔥 ${reward.streak}-day streak',
                          style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ).animate().scale(begin: const Offset(.6, .6), duration: 450.ms, curve: Curves.easeOutBack).fadeIn(),
              ],
            ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: rank != null ? 3100 : 1800)).fadeOut(duration: 400.ms),
    );
  }

  Widget _particle(Random rng, int i, Color c) {
    final angle = i * 2 * pi / 28 + rng.nextDouble() * .3;
    final dist = 110 + rng.nextDouble() * 130;
    final size = 3.0 + rng.nextDouble() * 5;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: c, boxShadow: [BoxShadow(color: c, blurRadius: 8)]),
    )
        .animate()
        .move(begin: Offset.zero, end: Offset(cos(angle) * dist, sin(angle) * dist), duration: 900.ms, curve: Curves.easeOutCubic)
        .fadeOut(delay: 500.ms, duration: 600.ms);
  }
}
