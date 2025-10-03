import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidGradientBackground extends StatefulWidget {
  const LiquidGradientBackground({super.key});

  @override
  State<LiquidGradientBackground> createState() =>
      _LiquidGradientBackgroundState();
}

class StarsPainter extends CustomPainter {
  final int starCount;
  final List<Offset> positions;
  final List<double> phases;
  final double t;

  StarsPainter({
    required this.starCount,
    required this.positions,
    required this.phases,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < starCount; i++) {
      final pos = positions[i];
      final dx = pos.dx * size.width;
      final dy = pos.dy * size.height;

      // twinkle with sine wave
      final twinkle = 0.6 + 0.4 * sin((t * 2 * pi) + phases[i]);
      final radius = 0.5 + 1.2 * twinkle;

      paint.color = Colors.white.withValues(alpha: twinkle);
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LiquidGradientBackgroundState extends State<LiquidGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final int starCount = 10;
  late List<Offset> starPositions;
  late List<double> starPhases;

  final int blobCount = 20;
  late List<Offset> centers;
  late List<Color> colors;
  late List<double> speeds;

  @override
  void initState() {
    super.initState();
    starPositions = List.generate(
      starCount,
      (_) => Offset(_random.nextDouble(), _random.nextDouble()),
    );

    starPhases = List.generate(starCount, (_) => _random.nextDouble() * 2 * pi);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    centers = List.generate(
      blobCount,
      (_) => Offset(_random.nextDouble(), _random.nextDouble()),
    );

    speeds = List.generate(blobCount, (_) => 0.2 + _random.nextDouble() * 0.5);

    // 🌌 Space nebula palette
    colors = [
      const Color(0xFF0F3460), // deep navy
      const Color(0xFF3A0CA3), // violet
      const Color(0xFF4361EE), // blue
      const Color(0xFF4CC9F0), // teal
      const Color(0xFFB5179E), // magenta
      const Color(0xFFF72585), // pink glow
      const Color(0xFFFF9E00), // star gas
      const Color(0xFF53354A), // muted purple
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B), // dark space background
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: LiquidPainter(
                  centers,
                  colors,
                  speeds,
                  _controller.value,
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(color: Colors.black.withValues(alpha: 0)),
              ),
              CustomPaint(
                painter: StarsPainter(
                  starCount: starCount,
                  positions: starPositions,
                  phases: starPhases,
                  t: _controller.value,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class LiquidPainter extends CustomPainter {
  final List<Offset> centers;
  final List<Color> colors;
  final List<double> speeds;
  final double t;

  LiquidPainter(this.centers, this.colors, this.speeds, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < centers.length; i++) {
      final dx =
          (centers[i].dx + sin(t * 2 * pi * speeds[i]) * 0.2) * size.width;
      final dy =
          (centers[i].dy + cos(t * 2 * pi * speeds[i]) * 0.2) * size.height;

      final radius = size.width * 0.45;

      final gradient = RadialGradient(
        colors: [
          colors[i % colors.length].withValues(alpha: 0.9), // bright core
          colors[i % colors.length].withValues(alpha: 0.4), // smoother mid glow
          Colors.transparent, // fade edges
        ],
        stops: const [0.0, 0.6, 1.0], // control blending
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: Offset(dx, dy), radius: radius),
        );

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
