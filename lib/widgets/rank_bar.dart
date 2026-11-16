import 'package:alter_ego/services/game_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Rank glyph, title, streak flame and progress to the next rank.
class RankBar extends StatelessWidget {
  final GameState state;
  final Color color;
  const RankBar({super.key, required this.state, required this.color});

  @override
  Widget build(BuildContext context) {
    final next = state.nextRank;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(state.rank.glyph, style: TextStyle(fontSize: 22, color: color))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(.92, .92), end: const Offset(1.08, 1.08), duration: 1400.ms),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.rank.title.toUpperCase(), style: const TextStyle(letterSpacing: 2.5, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      next == null ? '${state.xp} energy · highest rank' : '${state.xp} / ${next.minXp} energy to ${next.title}',
                      style: const TextStyle(fontSize: 11, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              _streak(),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(height: 6, color: Colors.white10),
                FractionallySizedBox(
                  widthFactor: state.progress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [color, Colors.white])),
                  ),
                ).animate().custom(duration: 900.ms, curve: Curves.easeOutCubic, builder: (context, v, child) => Align(alignment: Alignment.centerLeft, widthFactor: v, child: child)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _streak() {
    final active = state.streak > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (active ? Colors.orange : Colors.white).withAlpha(active ? 40 : 10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(active ? '🔥' : '·', style: const TextStyle(fontSize: 14))
              .animate(onPlay: (c) => active ? c.repeat(reverse: true) : null)
              .scale(begin: const Offset(.9, .9), end: const Offset(1.15, 1.15), duration: 700.ms),
          const SizedBox(width: 4),
          Text('${state.streak}', style: TextStyle(fontWeight: FontWeight.bold, color: active ? Colors.orangeAccent : Colors.white38)),
        ],
      ),
    );
  }
}
