import 'dart:math';

import 'package:flutter/material.dart';

/// Slowly drifting stars and a soft aura in the dominant voice's colour.
class MysticBackground extends StatefulWidget {
  final Color aura;
  final int stars;
  const MysticBackground({super.key, this.aura = const Color(0xff6C5CE7), this.stars = 70});

  @override
  State<MysticBackground> createState() => _MysticBackgroundState();
}

class _MysticBackgroundState extends State<MysticBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    final rng = Random(7);
    _stars = List.generate(widget.stars, (_) => _Star(rng.nextDouble(), rng.nextDouble(), rng.nextDouble() * 1.6 + .4, rng.nextDouble()));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _StarPainter(_stars, _c.value, widget.aura),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _Star {
  final double x, y, r, phase;
  _Star(this.x, this.y, this.r, this.phase);
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;
  final Color aura;
  _StarPainter(this.stars, this.t, this.aura);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFF0B0D12));
    final pulse = .5 + .5 * sin(t * 2 * pi * 2);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(.7, -.8),
          radius: 1.3,
          colors: [aura.withAlpha((50 + 30 * pulse).round()), Colors.transparent],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.9, .9),
          radius: 1.1,
          colors: [const Color(0xff3A1C71).withAlpha(60), Colors.transparent],
        ).createShader(rect),
    );
    final p = Paint();
    for (final s in stars) {
      final y = (s.y + t * .05 * s.r) % 1.0;
      final twinkle = .35 + .65 * (.5 + .5 * sin((t * 20 + s.phase * 6.28)));
      p.color = Colors.white.withAlpha((twinkle * 170).round());
      canvas.drawCircle(Offset(s.x * size.width, y * size.height), s.r, p);
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter old) => old.t != t || old.aura != aura;
}
