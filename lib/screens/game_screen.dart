
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/balloon_data.dart';
import '../models/game_stats.dart';
import '../widgets/balloon_widget.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  static const route = '/game';

  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int _maxLives = 5;

  static const List<Color> _balloonColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.deepPurple,
    Colors.amber,
  ];

  static const List<Color> _levelColors = [
    Color(0xFF80DEEA),
    Color(0xFFA5D6A7),
    Color(0xFFFFCC80),
    Color(0xFFCE93D8),
    Color(0xFFEF9A9A),
  ];

  final Random _rand = Random();
  final List<BalloonData> _balloons = [];
  final List<_PopEffect> _effects = [];

  Timer? _spawnTimer;

  int _score = 0;
  int _lives = _maxLives;
  int _combo = 0;
  int _comboBonus = 0;
  int _nextId = 0;
  bool _paused = false;
  bool _over = false;

  int get _level => _score ~/ 10;

  @override
  void initState() {
    super.initState();
    _scheduleSpawn();
  }

  @override
  void dispose() {
    _spawnTimer?.cancel();
    super.dispose();
  }

  void _scheduleSpawn() {
    _spawnTimer?.cancel();

    if (_paused || _over) return;

    final ms = max(450, 1100 - _score * 15);

    _spawnTimer = Timer(Duration(milliseconds: ms), () {
      if (!mounted || _paused || _over) return;

      _spawn();
      _scheduleSpawn();
    });
  }

  void _spawn() {
    if (!mounted || _paused || _over) return;

    final base = max(2500, 6000 - _score * 60);

    final data = BalloonData(
      id: _nextId++,
      x: _rand.nextDouble(),
      floatDuration: Duration(
        milliseconds: base + _rand.nextInt(1500),
      ),
      color: _balloonColors[
          _rand.nextInt(_balloonColors.length)],
      wobble: 1 + _rand.nextInt(3).toDouble(),
    );

    setState(() => _balloons.add(data));
  }

  void _onPopped(int id) {
    if (_over || _paused) return;

    final index = _balloons.indexWhere((b) => b.id == id);
    if (index == -1) return;

    final balloon = _balloons[index];

    setState(() {
      _balloons.removeWhere((b) => b.id == id);
      _combo++;
_comboBonus = _combo >= 10
    ? 30
    : _combo >= 5
        ? 15
        : _combo >= 3
            ? 5
            : 0;

_score += 1 + _comboBonus;

      // Add colorful confetti and sparkles.
      final effect = _PopEffect(
        id: id,
        x: balloon.x,
        color: balloon.color,
      );

      _effects.add(effect);
    });

    // Remove the visual effect after its animation.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;

      setState(() {
        _effects.removeWhere((effect) => effect.id == id);
      });
    });
  }

  void _onEscaped(int id) {
    if (_over || _paused) return;

    setState(() {
      _balloons.removeWhere((b) => b.id == id);
      _lives = max(0, _lives - 1);
    });

    if (_lives == 0) {
      _gameOver();
    }
  }

  void _gameOver() {
    if (_over) return;

    _over = true;
    _spawnTimer?.cancel();

    GameStats.submit(_score);

    Navigator.pushReplacementNamed(
      context,
      GameOverScreen.route,
      arguments: _score,
    );
  }

  void _togglePause() {
    if (_over) return;

    setState(() => _paused = !_paused);

    if (_paused) {
      _spawnTimer?.cancel();
    } else {
      _scheduleSpawn();
    }
  }

  Widget _hud() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_maxLives, (i) {
              final alive = i < _lives;

              return AnimatedScale(
                scale: alive ? 1 : 0.7,
                duration: const Duration(milliseconds: 250),
                child: Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(
                    alive ? Icons.favorite : Icons.favorite_border,
                    color: alive ? Colors.redAccent : Colors.grey,
                    size: 23,
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              '⭐ $_score',
              key: ValueKey(_score),
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF553399),
              ),
            ),
          ),
          const Spacer(),
          Text(
            'LV ${_level + 1}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00838F),
            ),
          ),
          IconButton(
            tooltip: _paused ? 'Resume' : 'Pause',
            onPressed: _togglePause,
            icon: Icon(
              _paused ? Icons.play_circle_fill : Icons.pause_circle,
              color: const Color(0xFF6A3DB8),
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopEffects() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            for (final effect in _effects)
              Positioned(
                left: effect.x * MediaQuery.sizeOf(context).width - 35,
                top: MediaQuery.sizeOf(context).height * 0.42,
                child: _PopBurst(
                  color: effect.color,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _pauseOverlay() {
    return Positioned.fill(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _paused
            ? Container(
                key: const ValueKey('paused'),
                color: Colors.black54,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.pause_circle_filled,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'GAME PAUSED',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _togglePause,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Resume Game'),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(
                key: ValueKey('running'),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _levelColors[_level % _levelColors.length];

    return Scaffold(
      body: TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: levelColor),
        duration: const Duration(milliseconds: 1000),
        builder: (context, color, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color ?? levelColor,
                  const Color(0xFFFFF3FA),
                  const Color(0xFFEDE7FF),
                ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              _hud(),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '🎈 Pop the balloons!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF553399),
                  ),
                ),
              ),
              Expanded(
                child: ClipRect(
                  child: Stack(
                    children: [
                      for (final balloon in _balloons)
                        Positioned.fill(
                          key: ValueKey(balloon.id),
                          child: BalloonWidget(
                            data: balloon,
                            paused: _paused,
                            onPopped: _onPopped,
                            onEscaped: _onEscaped,
                          ),
                        ),
                      _buildPopEffects(),
                      _pauseOverlay(),
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

class _PopEffect {
  final int id;
  final double x;
  final Color color;

  const _PopEffect({
    required this.id,
    required this.x,
    required this.color,
  });
}

class _PopBurst extends StatefulWidget {
  final Color color;

const _PopBurst({required this.color});

  @override
  State<_PopBurst> createState() => _PopBurstState();
}

class _PopBurstState extends State<_PopBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;

        return Opacity(
          opacity: 1 - progress,
          child: Transform.scale(
            scale: 0.4 + progress * 1.8,
            child: SizedBox(
              width: 70,
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.stars_rounded,
                    size: 50 * (1 - progress * 0.5),
                    color: widget.color,
                  ),
                  Positioned(
                    top: 0,
                    right: 4,
                    child: Text(
                      '+1',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: widget.color,
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 4,
                    child: Text(
                      '✨',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
