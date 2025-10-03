// space_shooter_flame_main.dart
// Polished Flame + Flutter single-file game (lib/main.dart)
// Features fixed and improved:
// - Proper Flame collision using CircleHitbox (avoids padded-image false collisions)
// - Explosion effect on death (expanding/fading circle)
// - Vertical flare indicator rendered in Flutter overlay (gradient line)
// - Player can move left/right/up/down with on-screen buttons
// - Difficulty (speed & spawn rate) increases over time
// - High score saved/loaded via HiveFunctions (async, type-safe)
// - Cleaner, compile-ready code (Flame 1.x compatible)

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/flame.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:nasa_app/utils/hive_functions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setPortrait();
  runApp(const MaterialApp(home: RaceGameHost()));
}

class RaceGameHost extends StatelessWidget {
  const RaceGameHost({super.key});

  @override
  Widget build(BuildContext context) {
    final game = SpaceShooterGame();
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'Space Racing',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: GameWidget<SpaceShooterGame>(
        game: game,
        overlayBuilderMap: {
          'HUD': (ctx, g) => HudOverlay(game: g),
          'GameOver': (ctx, g) => GameOverOverlay(game: g),
        },
        initialActiveOverlays: const ['HUD'],
      ),
    );
  }
}

class SpaceShooterGame extends FlameGame with HasCollisionDetection {
  late Player player;
  late Sprite
  playerSprite; // keep sprite so we can recreate player without async
  final Random rnd = Random();

  // spawn & difficulty
  double asteroidSpawnTimer = 0.0;
  double asteroidSpawnInterval = 1.2; // start slower
  double minAsteroidInterval = 0.35;

  double celestialSpawnTimer = 0.0;
  double celestialSpawnInterval = 3.0;

  double sunEventTimer = 0.0;
  double sunEventInterval = 6.0; // randomized

  double timeSinceStart = 0.0; // used to increase difficulty over time

  @override
  bool paused = false;

  int score = 0;
  double scoreAcc = 0.0;
  int highScore = 0;

  late SpriteComponent sun;
  final List<Body> hazards = [];

  // flare indicator state for Flutter overlay
  bool showFlareIndicator = false;
  double? activeFlareX;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await images.loadAll([
      'rocket.png',
      'sun.png',
      'asteroid1.png',
      'asteroid2.png',
      'planet1.png',
      'flare.png',
      'indicator.png',
    ]);

    playerSprite = await loadSprite('rocket.png');

    // Player
    player = Player()
      ..sprite = playerSprite
      ..size = Vector2(64, 64)
      ..anchor = Anchor.center
      ..position = Vector2(size.x / 2, size.y - 120);
    add(player);

    // Sun at top center (decorative)
    sun = SpriteComponent()
      ..sprite = await loadSprite('sun.png')
      ..size = Vector2(140, 140)
      ..anchor = Anchor.topCenter
      ..position = Vector2(size.x / 2, -10);
    add(sun);

    // Load high score using async HiveFunctions safely
    final saved = await HiveFunctions.getData('high_score');
    highScore = (saved is int) ? saved : 0;

    // randomize first sun event time
    sunEventTimer = 0;
    sunEventInterval = 4 + rnd.nextDouble() * 6; // 4..10s
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (paused) return;

    timeSinceStart += dt;

    // Smooth difficulty curve: - lower the spawn interval and increase speeds over time
    final difficulty = 1.0 + (timeSinceStart / 45.0); // +1 every 45s

    asteroidSpawnTimer += dt;
    final currentAsteroidInterval =
        (asteroidSpawnInterval - (timeSinceStart * 0.007)).clamp(
          minAsteroidInterval,
          5.0,
        );
    if (asteroidSpawnTimer > currentAsteroidInterval) {
      asteroidSpawnTimer = 0;
      spawnAsteroid(difficulty);
    }

    celestialSpawnTimer += dt;
    if (celestialSpawnTimer > celestialSpawnInterval) {
      celestialSpawnTimer = 0;
      spawnCelestial(difficulty);
    }

    // sun events (CME / flare)
    sunEventTimer += dt;
    if (sunEventTimer > sunEventInterval) {
      sunEventTimer = 0;
      sunEventInterval = 4 + rnd.nextDouble() * 8; // next time
      startSunEvent();
    }

    // update score by survival time (faster as difficulty increases)
    scoreAcc += dt * (10.0 * (1.0 + timeSinceStart / 60.0));
    if (scoreAcc >= 1) {
      score += scoreAcc.floor();
      scoreAcc -= scoreAcc.floor();
    }

    // remove hazards that flagged removed
    hazards.removeWhere((h) => h.isRemoved);
  }

  void spawnAsteroid(double difficulty) async {
    final which = rnd.nextInt(2);
    final spriteName = which == 0 ? 'asteroid1.png' : 'asteroid2.png';
    final sprite = await loadSprite(spriteName);
    final sizeVal = 28.0 + rnd.nextDouble() * 56.0;
    final speed = (120 + rnd.nextDouble() * 160) * difficulty;
    final body = Body(sprite: sprite, size: Vector2.all(sizeVal))
      ..anchor = Anchor.center
      ..position = Vector2(16 + rnd.nextDouble() * (size.x - 32), -sizeVal)
      ..velocity = Vector2(0, speed);
    hazards.add(body);
    add(body);
  }

  void spawnCelestial(double difficulty) async {
    final sprite = await loadSprite('planet1.png');
    final sizeVal = 60.0 + rnd.nextDouble() * 80.0;
    final vx =
        (rnd.nextBool() ? 1 : -1) *
        (40 + rnd.nextDouble() * 80) *
        (0.3 + timeSinceStart / 120.0);
    final xStart = vx > 0 ? -sizeVal : size.x + sizeVal;
    final body = Body(sprite: sprite, size: Vector2.all(sizeVal))
      ..anchor = Anchor.center
      ..position = Vector2(xStart, 120 + rnd.nextDouble() * (size.y / 2))
      ..velocity = Vector2(vx, 20 + rnd.nextDouble() * 30);
    hazards.add(body);
    add(body);
  }

  void startSunEvent() {
    // choose target X for flare (center)
    final flareX = 40 + rnd.nextDouble() * (size.x - 80);
    activeFlareX = flareX;
    showFlareIndicator = true;

    // Indicator visible briefly; then spawn fast flare
    Future.delayed(const Duration(milliseconds: 650), () async {
      showFlareIndicator = false;
      final flareSprite = await loadSprite('flare.png');
      final flare = Body(sprite: flareSprite, size: Vector2(96, 140))
        ..anchor = Anchor.center
        ..position = Vector2(flareX, sun.position.y + sun.size.y / 2 + 30)
        ..isFlare = true
        ..velocity = Vector2(
          0,
          400 + timeSinceStart * 2,
        ); // gets faster over time
      hazards.add(flare);
      add(flare);

      // flare lasts briefly then disappears
      Future.delayed(const Duration(milliseconds: 900), () {
        flare.removeFromParent();
      });
    });
  }

  void onPlayerDead() async {
    if (paused) return;
    paused = true;
    player.alive = false;

    // explosion at center of player
    final center = player.position.clone();
    add(ExplosionEffect(center));
    player.removeFromParent();

    if (score > highScore) {
      highScore = score;
      await HiveFunctions.putData('high_score', highScore);
    }

    overlays.remove('HUD');
    overlays.add('GameOver');
  }

  void resetGame() {
    // remove hazards
    for (final h in List<Body>.from(hazards)) {
      h.removeFromParent();
    }
    hazards.clear();

    // recreate player using stored sprite
    player = Player()
      ..sprite = playerSprite
      ..size = Vector2(64, 64)
      ..anchor = Anchor.center
      ..position = Vector2(size.x / 2, size.y - 120);
    add(player);

    // reset timers and scores
    asteroidSpawnInterval = 1.2;
    asteroidSpawnTimer = 0;
    celestialSpawnTimer = 0;
    sunEventTimer = 0;
    sunEventInterval = 4 + rnd.nextDouble() * 6;
    timeSinceStart = 0.0;
    score = 0;
    scoreAcc = 0;
    paused = false;

    overlays.remove('GameOver');
    overlays.add('HUD');
  }
}

class Player extends SpriteComponent
    with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
  bool leftPressed = false;
  bool rightPressed = false;
  bool upPressed = false;
  bool downPressed = false;
  double speed = 260; // px/sec (responsive)
  bool alive = true;

  Player({Sprite? sprite}) : super();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // add small circular hitbox to avoid padded PNG collision issues
    final hb = CircleHitbox()
      ..collisionType = CollisionType.active
      ..radius = min(size.x, size.y) * 0.42; // approximate visible area
    add(hb);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!alive) return;

    double dx = (rightPressed ? 1 : 0) - (leftPressed ? 1 : 0);
    double dy = (downPressed ? 1 : 0) - (upPressed ? 1 : 0);

    // normalize diagonal speed
    final move = Vector2(dx, dy);
    if (move.length > 1) move.normalize();

    position += move * speed * dt;

    // keep inside screen bounds with margin
    final halfW = size.x / 2;
    final halfH = size.y / 2;
    position.x = position.x.clamp(halfW, game.size.x - halfW);
    position.y = position.y.clamp(halfH + 40, game.size.y - halfH - 20);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Body) {
      // collide only if other is not removed and is an actual hazard
      if (!other.isRemoving) {
        game.onPlayerDead();
      }
    }
  }
}

class Body extends SpriteComponent
    with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
  Vector2 velocity = Vector2.zero();
  bool isFlare = false;

  Body({super.sprite, super.size}) {
    // nothing
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // circle hitbox — good enough for asteroids and planets; smaller radius prevents border collisions
    final hb = CircleHitbox()
      ..collisionType = CollisionType.passive
      ..radius = min(size.x, size.y) * 0.45;
    add(hb);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    // remove when off-screen
    if (position.y > game.size.y + 300 ||
        position.x < -600 ||
        position.x > game.size.x + 600) {
      removeFromParent();
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Player) {
      // player will handle death
      game.onPlayerDead();
    }
  }
}

class ExplosionEffect extends PositionComponent {
  double life = 0.9; // seconds
  double elapsed = 0.0;
  Paint paint = Paint()..style = PaintingStyle.fill;
  double startRadius = 8;
  double endRadius = 140;

  ExplosionEffect(Vector2 center) {
    position = center;
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    final t = (elapsed / life).clamp(0.0, 1.0);
    final currentRadius = lerpDouble(startRadius, endRadius, t)!;
    paint.color = Color.lerp(
      Colors.orange,
      Colors.deepOrange,
      t,
    )!.withValues(alpha: 1.0 - t);
    canvas.drawCircle(Offset.zero, currentRadius, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    elapsed += dt;
    if (elapsed >= life) removeFromParent();
  }
}

// HUD overlay widget
class HudOverlay extends StatefulWidget {
  final SpaceShooterGame game;
  const HudOverlay({required this.game, super.key});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  @override
  void initState() {
    super.initState();
    // update every 60ms to reflect game changes
    Future.doWhile(() async {
      if (!mounted) return false;
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 60));
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Map game.activeFlareX (game coordinates) to overlay left position. Game widget uses logical pixels so this should align.
    double? flareLeft;
    if (game.showFlareIndicator && game.activeFlareX != null) {
      flareLeft = game.activeFlareX! - 12; // center the 24px-wide line
    }

    return Stack(
      children: [
        // score
        Positioned(
          top: 36,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Score: ${game.score}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Positioned(
          top: 36,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'High: ${game.highScore}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // flare indicator (vertical gradient line)
        if (flareLeft != null)
          Positioned(
            top: 120,
            left: flareLeft.clamp(0.0, screenWidth - 24),
            child: SizedBox(
              width: 24,
              height: screenHeight,
              child: IgnorePointer(
                ignoring: true,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.redAccent.withValues(alpha: 0.95),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent.withValues(alpha: 0.28),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        // small sun flash marker
        if (game.showFlareIndicator && game.activeFlareX != null)
          Positioned(
            top: 92,
            left: (game.activeFlareX! - 20).clamp(0.0, screenWidth - 40),
            child: Container(
              width: 40,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.yellowAccent.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

        // Control buttons: Left, Right, Up, Down
        Positioned(
          bottom: 24,
          left: 16,
          child: Column(
            children: [
              GestureDetector(
                onTapDown: (_) => game.player.upPressed = true,
                onTapUp: (_) => game.player.upPressed = false,
                onTapCancel: () => game.player.upPressed = false,
                child: ControlButton(icon: Icons.arrow_drop_up),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTapDown: (_) => game.player.downPressed = true,
                onTapUp: (_) => game.player.downPressed = false,
                onTapCancel: () => game.player.downPressed = false,
                child: ControlButton(icon: Icons.arrow_drop_down),
              ),
            ],
          ),
        ),

        Positioned(
          bottom: 24,
          right: 16,
          child: Column(
            children: [
              GestureDetector(
                onTapDown: (_) => game.player.leftPressed = true,
                onTapUp: (_) => game.player.leftPressed = false,
                onTapCancel: () => game.player.leftPressed = false,
                child: ControlButton(icon: Icons.arrow_left),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTapDown: (_) => game.player.rightPressed = true,
                onTapUp: (_) => game.player.rightPressed = false,
                onTapCancel: () => game.player.rightPressed = false,
                child: ControlButton(icon: Icons.arrow_right),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ControlButton extends StatelessWidget {
  final IconData icon;
  const ControlButton({required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 36),
    );
  }
}

// Game over overlay
class GameOverOverlay extends StatelessWidget {
  final SpaceShooterGame game;
  const GameOverOverlay({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(color: Colors.white, fontSize: 36),
            ),
            const SizedBox(height: 12),
            Text(
              'Score: ${game.score}',
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'High: ${game.highScore}',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => game.resetGame(),
                  child: const Text('Restart'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Exit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*
Assets to add (place under assets/ and list in pubspec.yaml):
 - assets/rocket.png        (player sprite, 64x64 recommended, transparent PNG)
 - assets/sun.png           (sun image, ~200x200)
 - assets/asteroid1.png     (tight-cropped asteroid graphic)
 - assets/asteroid2.png     (tight-cropped)
 - assets/planet1.png       (tight-cropped celestial body)
 - assets/flare.png         (solar flare graphic)
 - assets/indicator.png     (optional)

pubspec.yaml additions:

flutter:
  assets:
    - assets/rocket.png
    - assets/sun.png
    - assets/asteroid1.png
    - assets/asteroid2.png
    - assets/planet1.png
    - assets/flare.png
    - assets/indicator.png

dependencies:
  flame: ^1.5.0

Notes:
- If collision still feels "too generous" because your sprite is irregular, provide explosion frames and we can use a pixel-perfect polygon hitbox.
- You can tune the difficulty curve by editing the `difficulty` calculation in update() and velocities in spawn functions.
*/
