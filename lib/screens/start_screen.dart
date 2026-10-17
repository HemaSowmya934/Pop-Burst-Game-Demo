
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/game_stats.dart';
import 'game_screen.dart';

class StartScreen extends StatefulWidget {
  static const route = '/';

  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _float;
  late final Animation<double> _titleFade;
  late final Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _titleFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
    );

    _buttonScale = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.5, 1, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _float.dispose();
    super.dispose();
  }

  Widget _balloon(
    Color color,
    double size,
    double rotation,
    double offset,
  ) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, child) {
        final movement =
            math.sin(_float.value * math.pi + offset) * 15;

        return Transform.translate(
          offset: Offset(0, movement),
          child: Transform.rotate(
            angle: rotation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: size,
                  height: size * 1.2,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(size * 0.55),
                      topRight: Radius.circular(size * 0.55),
                      bottomLeft: Radius.circular(size * 0.45),
                      bottomRight: Radius.circular(size * 0.45),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.65),
                        color,
                        color.withValues(alpha: 0.85),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: const Alignment(-0.35, -0.35),
                    child: Container(
                      width: size * 0.16,
                      height: size * 0.28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 9,
                  height: 8,
                  color: color,
                ),
                Container(
                  width: 1.5,
                  height: size * 0.8,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _feature(IconData icon, String title) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: const Color(0xFF7048C8), size: 27),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF51416D),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB9E8FF),
              Color(0xFFE7D9FF),
              Color(0xFFFFE3EE),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 45,
                left: 18,
                child: _balloon(
                  const Color(0xFFFF668C), 42, -0.15, 0.2,
                ),
              ),
              Positioned(
                top: 105,
                right: 22,
                child: _balloon(
                  const Color(0xFFFFC857), 52, 0.12, 1.2,
                ),
              ),
              Positioned(
                top: 255,
                left: 12,
                child: _balloon(
                  const Color(0xFF9874FF), 34, 0.12, 2.2,
                ),
              ),
              Positioned(
                top: 300,
                right: 12,
                child: _balloon(
                  const Color(0xFF36CFC9), 40, -0.12, 0.7,
                ),
              ),
              Positioned(
                bottom: 60,
                left: 24,
                child: _balloon(
                  const Color(0xFFFF9F43), 35, 0.1, 1.8,
                ),
              ),
              Positioned(
                bottom: 90,
                right: 28,
                child: _balloon(
                  const Color(0xFFFF668C), 43, -0.1, 2.8,
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 25,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _titleFade,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF8456D9),
                                size: 19,
                              ),
                              SizedBox(width: 7),
                              Text(
                                'THE HAPPY POPPING GAME',
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6846A4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ScaleTransition(
                        scale: _buttonScale,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.55),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9A70E8)
                                    .withValues(alpha: 0.2),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '🎈',
                              style: TextStyle(fontSize: 100),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      FadeTransition(
                        opacity: _titleFade,
                        child: const Text(
                          'POP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 43,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: Color(0xFF56339B),
                          ),
                        ),
                      ),
                      FadeTransition(
                        opacity: _titleFade,
                        child: const Text(
                          'BURST!',
                          style: TextStyle(
                            fontSize: 55,
                            height: 1.1,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 5,
                            color: Color(0xFFFF5983),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeTransition(
                        opacity: _titleFade,
                        child: const Text(
                          'Pop fast. Build combos. Be the champion!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF625577),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              color: Color(0xFFFFB52E),
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'YOUR BEST SCORE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 1,
                                    color: Color(0xFF817393),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${GameStats.best} POINTS',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF56339B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      ScaleTransition(
                        scale: _buttonScale,
                        child: SizedBox(
                          width: double.infinity,
                          height: 62,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF8456E8),
                                  Color(0xFFFF668C),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8456E8)
                                      .withValues(alpha: 0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  GameScreen.route,
                                );
                              },
                              icon: const Icon(
                                Icons.play_arrow_rounded,
                                size: 32,
                              ),
                              label: const Text(
                                'PLAY NOW',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _feature(
                            Icons.favorite_rounded,
                            '5 LIVES',
                          ),
                          const SizedBox(width: 30),
                          _feature(
                            Icons.bolt_rounded,
                            'FAST ACTION',
                          ),
                          const SizedBox(width: 30),
                          _feature(
                            Icons.star_rounded,
                            'HIGH SCORE',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'READY, SET, POP! ✨',
                        style: TextStyle(
                          color: Color(0xFF8A719E),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
