import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  // The core animation loop that ticks every frame
  late AnimationController _controller;

  // The master list of all active particles on the screen
  final List<Particle> _particles = [];

  // Seed for random number generation
  final Random _random = Random();

  // Total number of particles to spawn and simulate
  final int _particleCount = 100;

  // Stream that listens to bare metal hardware accelerometer data
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // The raw hardware reading of device tilt
  double _accelX = 0.0;
  double _accelY = 0.0;

  // Interpolated (smoothed) values for parallax movement.
  // We use a low-pass filter so the particles don't instantly snap when the phone jerks.
  double _smoothAccelX = 0.0;
  double _smoothAccelY = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initParticles(MediaQuery.of(context).size);
    });

    _accelerometerSubscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        if (mounted) {
          setState(() {
            _accelX = event.x;
            _accelY = event.y;
          });
        }
      },
      onError: (error) {
        // Ignore sensor stream errors (e.g. desktop environment without sensors)
      },
    );
  }

  /// Spawns the initial batch of particles. Must be called after layout
  /// so we know the true screen [size] bounds.
  void _initParticles(Size size) {
    if (_particles.isNotEmpty) return;

    // Generate the mathematical particles
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(Particle.random(size, _random));
    }

    // Trigger a rebuild now that particles exist so the UI actually renders them
    setState(() {});
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_particles.isEmpty) {
      // Particles haven't spawned yet because we are waiting for the
      // addPostFrameCallback to give us the screen size.
      return const SizedBox();
    }

    // AnimatedBuilder listens to the _controller and rebuilds the CustomPaint every frame
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // LERP (Linear Interpolation):
        // Move the smoothed accelerometer value 10% of the way towards the raw hardware reading.
        // This isolates the particles from jittery hands.
        _smoothAccelX += (_accelX - _smoothAccelX) * 0.1;
        _smoothAccelY += (_accelY - _smoothAccelY) * 0.1;

        // Step 1: Calculate the new physical positions of all particles
        _updateParticles(
          MediaQuery.of(context).size,
          _smoothAccelX,
          _smoothAccelY,
        );

        // Step 2: Draw those new positions to the screen using CustomPaint
        return CustomPaint(
          size: Size.infinite,
          painter: ParticlePainter(_particles),
        );
      },
    );
  }

  void _updateParticles(Size size, [double accelX = 0.0, double accelY = 0.0]) {
    for (var particle in _particles) {
      particle.update(size, _random, accelX, accelY);
    }
  }
}

/// Represents a single glowing dust particle in the background.
class Particle {
  /// Current exact X position on the screen
  double x;

  /// Current exact Y position on the screen
  double y;

  /// Velocity on the X axis (horizontal drift speed)
  double vx;

  /// Velocity on the Y axis (vertical drift speed)
  double vy;

  /// The radius of the particle. Larger sizes appear closer to the camera.
  double size;

  /// The base color of the particle
  Color color;

  /// The opacity of the particle's core and glow. 1.0 is fully opaque.
  double alpha;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.alpha,
  });

  /// Factory method to generate a randomized particle.
  /// This configures the initial aesthetic layout (colors, sizes, opacities).
  static Particle random(Size bounds, Random random) {
    // A palette of highly saturated, electric colors for a neon sci-fi feel
    final colors = [
      const Color(0xFF00FFFF), // Electric Cyan
      const Color(0xFFE5FF00), // Electric/Neon Yellow
      const Color(0xFF0055FF), // Deep Electric Blue
    ];

    // GENERATING SIZE:
    // Sizes are completely random between 1.0 and 4.0.
    // - 1.0 represents "deep background" dust.
    // - 4.0 represents "close foreground" dust.
    final size = random.nextDouble() * 3 + 1;

    // GENERATING OPACITY (ALPHA):
    // We scale the opacity proportionally to the physical size.
    // This perfectly fakes depth of field: tiny particles in the deep background
    // should be barely visible (low alpha), while large foreground particles should glow brightly.
    // Min size (1.0) gets ~0.15 alpha. Max size (4.0) gets ~0.4 alpha.
    final alpha = 0.1 + ((size / 4.0) * 0.3);

    return Particle(
      // Spawn at a completely random point across the entire screen
      x: random.nextDouble() * bounds.width,
      y: random.nextDouble() * bounds.height,

      // GENERATING VELOCITY:
      // (random - 0.5) generates a value between -0.5 and +0.5.
      // We multiply by a small scalar (0.2x and 0.1y) to make the drift extremely slow and graceful.
      vx: (random.nextDouble() - 0.5) * 0.2, // Float randomly left/right
      vy: (random.nextDouble() - 0.5) * 0.1, // Float randomly up/down

      size: size,
      color: colors[random.nextInt(colors.length)],
      alpha: alpha,
    );
  }

  /// Called every single frame (typically 60 times a second) to move the particle.
  /// [accelX] and [accelY] are the current smoothed device tilt values.
  void update(
    Size bounds,
    Random random, [
    double accelX = 0.0,
    double accelY = 0.0,
  ]) {
    // 1. INTRINSIC MOTION: Apply the constant slow drift
    x += vx;
    y += vy;

    // 2. PARALLAX OFFSET (ACCELEROMETER):
    // We shift the particle in the opposite direction of the device tilt.
    // CRITICAL: We multiply the shift by the particle's `size`.
    // Because larger particles shift further, it creates a 3D parallax illusion
    // where large particles look like they are floating "above" the screen,
    // and small particles look like they are deep "inside" the screen.
    x -= accelX * size * 0.2;
    y += accelY * size * 0.2;

    // 3. SCREEN WRAPPING:
    // If a particle floats completely off one edge of the screen, we instantly
    // teleport it to the opposite edge. We add 50px of padding so it fully clears
    // the visible screen before snapping, preventing ugly visual pop-in.
    if (x < -50) x = bounds.width + 50;
    if (x > bounds.width + 50) x = -50;
    if (y < -50) y = bounds.height + 50;
    if (y > bounds.height + 50) y = -50;
  }
}

/// The CustomPainter responsible for drawing the particles onto the canvas every frame.
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // VISUAL RENDERING:
      // We create a glowing aesthetic using a MaskFilter.blur.
      // 1. The main color is applied with the calculated depth-based alpha.
      // 2. The blur radius is scaled exactly to the physical particle size (size * 1).
      // This means big foreground particles cast huge, soft glows, while tiny background
      // particles look like sharp, distant pinpricks of light.
      final paint = Paint()
        ..color = particle.color.withValues(alpha: particle.alpha)
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          particle.size * 1, // Blur scales 1:1 with size
        );

      // Draw the mathematical circle to the screen
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);
    }
  }

  // We are animating every frame, so we always want to repaint.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
