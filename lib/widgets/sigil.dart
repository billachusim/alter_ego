import 'dart:math';

import 'package:flutter/material.dart';

/// A slowly turning glowing sigil with the identity's glyph in the centre.
class Sigil extends StatefulWidget {
  final String glyph;
  final Color color;
  final double size;
  const Sigil({super.key, required this.glyph, required this.color, this.size = 72});

  @override
  State<Sigil> createState() => _SigilState();
}

class _SigilState extends State<Sigil> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: _c.value * 2 * pi,
              child: CustomPaint(size: Size.square(widget.size), painter: _RingPainter(widget.color)),
            ),
            Transform.rotate(
              angle: -_c.value * 2 * pi * 1.5,
              child: CustomPaint(size: Size.square(widget.size * .72), painter: _RingPainter(widget.color, points: 6, dashed: true)),
            ),
            child!,
          ],
        ),
        child: Container(
          width: widget.size * .5,
          height: widget.size * .5,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withAlpha(40),
            boxShadow: [BoxShadow(color: widget.color.withAlpha(140), blurRadius: 24, spreadRadius: 2)],
          ),
          child: Text(widget.glyph, style: TextStyle(fontSize: widget.size * .26, color: Colors.white)),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final int points;
  final bool dashed;
  _RingPainter(this.color, {this.points = 9, this.dashed = false});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 2;
    final paint = Paint()
      ..color = color.withAlpha(dashed ? 110 : 160)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    if (dashed) {
      for (var i = 0; i < 24; i += 2) {
        canvas.drawArc(Rect.fromCircle(center: c, radius: r), i * pi / 12, pi / 14, false, paint);
      }
    } else {
      canvas.drawCircle(c, r, paint);
    }
    final dot = Paint()..color = color;
    final path = Path();
    for (var i = 0; i < points; i++) {
      final a = i * 2 * pi / points - pi / 2;
      final o = c + Offset(cos(a), sin(a)) * r;
      canvas.drawCircle(o, dashed ? 1.5 : 2.2, dot);
      if (!dashed) {
        final b = (i + points ~/ 2) * 2 * pi / points - pi / 2;
        path
          ..moveTo(o.dx, o.dy)
          ..lineTo(c.dx + cos(b) * r, c.dy + sin(b) * r);
      }
    }
    if (!dashed) {
      canvas.drawPath(path, Paint()..color = color.withAlpha(45)..style = PaintingStyle.stroke..strokeWidth = .8);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.color != color;
}
