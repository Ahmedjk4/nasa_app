import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nasa_app/screens/splash_screen.dart';

class RocketTransitionWidget extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const RocketTransitionWidget({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    final rocketAppear = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );

    final pageSlide = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // New page (HomeScreen) - stays in place
            child,

            // Old page sliding up with rocket
            if (animation.value < 0.95) // Hide when almost complete
              Transform.translate(
                offset: Offset(0, -screenHeight * pageSlide.value),
                child: Container(
                  color: Colors.black, // Prevent transparency issues
                  child: Stack(
                    children: [
                      // The actual splash screen content
                      IgnorePointer(child: const SplashScreen()),

                      // Rocket at the bottom pushing the page up
                      Positioned(
                        bottom: -50 + (100 * rocketAppear.value),
                        left: 0,
                        right: 0,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: animation.value < 0.9 ? 1.0 : 0.0,
                          child: const RocketPushEffect(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class RocketPushEffect extends StatelessWidget {
  const RocketPushEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rocket body
        Container(
          width: 60,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.grey.shade300, Colors.grey.shade600],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
              bottom: Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rocket window
              Positioned(
                top: 15,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.lightBlue.shade200, Colors.blue.shade600],
                    ),
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                  ),
                ),
              ),
              // Rocket fins
              Positioned(bottom: 5, left: -10, child: _buildFin(true)),
              Positioned(bottom: 5, right: -10, child: _buildFin(false)),
            ],
          ),
        ),
        // Fire effect
        const SizedBox(height: 5),
        const FireEffect(),
      ],
    );
  }

  Widget _buildFin(bool isLeft) {
    return Transform.rotate(
      angle: isLeft ? -0.3 : 0.3,
      child: Container(
        width: 20,
        height: 30,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade600, Colors.red.shade800],
          ),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}

class FireEffect extends StatefulWidget {
  const FireEffect({super.key});

  @override
  State<FireEffect> createState() => _FireEffectState();
}

class _FireEffectState extends State<FireEffect> with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  final List<double> _widths = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 8; i++) {
      final durationMs = 200 + _random.nextInt(300);
      final c = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationMs),
      )..repeat(reverse: true);
      _controllers.add(c);
      _widths.add(8 + _random.nextDouble() * 6);
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_controllers.length, (i) {
          return AnimatedBuilder(
            animation: _controllers[i],
            builder: (_, __) {
              final value = _controllers[i].value;
              final height = 25 + 35 * value;
              final width = _widths[i] * (1 + value * 0.3);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                width: width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(width / 2),
                    bottom: Radius.circular(width / 4),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.yellowAccent.withValues(
                        alpha: (0.9 - value * 0.4).clamp(0.3, 1),
                      ),
                      Colors.orangeAccent.withValues(
                        alpha: (0.8 - value * 0.3).clamp(0.2, 1),
                      ),
                      Colors.deepOrange.withValues(
                        alpha: (0.6 - value * 0.2).clamp(0.1, 1),
                      ),
                      Colors.red.shade900.withValues(
                        alpha: (0.4 - value * 0.2).clamp(0, 0.8),
                      ),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.3 * (1 - value)),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
