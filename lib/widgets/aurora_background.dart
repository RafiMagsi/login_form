import 'dart:math';

import 'package:flutter/material.dart';

/// A dark mesh-gradient wallpaper with warm glowing blobs drifting slowly.
/// Painted with a [CustomPainter] (one shader per blob), so it stays smooth
/// and cheap while content scrolls over it.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({super.key});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 36),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _AuroraPainter(_controller),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _Blob {
  const _Blob(this.color, this.anchor, this.radius, this.phase, this.speed);

  final Color color;
  final Offset anchor; // resting position, as a fraction of the screen
  final double radius; // as a fraction of the screen's longest side
  final double phase;
  final double speed;
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.animation) : super(repaint: animation);

  final Animation<double> animation;

  static const _blobs = [
    _Blob(Color(0xFFFF6A2B), Offset(0.95, 0.04), 0.55, 0.0, 1.0),
    _Blob(Color(0xFF6D4BFF), Offset(0.00, 0.34), 0.55, 2.1, 1.0),
    _Blob(Color(0xFFFF2D75), Offset(0.92, 0.72), 0.50, 4.0, 1.0),
    _Blob(Color(0xFF3B3FE0), Offset(0.10, 0.96), 0.52, 5.3, 1.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C0E19), Color(0xFF130C20)],
        ).createShader(rect),
    );

    final t = animation.value * 2 * pi;
    final longest = max(size.width, size.height);

    for (final b in _blobs) {
      final a = t * b.speed + b.phase;
      final center = Offset(
        (b.anchor.dx + 0.10 * sin(a)) * size.width,
        (b.anchor.dy + 0.08 * cos(a * 1.2)) * size.height,
      );
      final radius = b.radius * longest;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              b.color.withValues(alpha: 0.5),
              b.color.withValues(alpha: 0.18),
              b.color.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    // Soft vignette keeps the edges calm so content pops.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 1.1,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.4)],
          stops: const [0.55, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) => false;
}
