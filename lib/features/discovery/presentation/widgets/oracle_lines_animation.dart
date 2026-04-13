import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:serapeum_app/core/constants/app_colors.dart';

class OracleLinesAnimation extends StatefulWidget {
  final bool isSearching;

  const OracleLinesAnimation({super.key, required this.isSearching});

  @override
  State<OracleLinesAnimation> createState() => _OracleLinesAnimationState();
}

class _OracleLinesAnimationState extends State<OracleLinesAnimation>
    with TickerProviderStateMixin {
  late final Ticker _ticker;
  final _elapsedNotifier = ValueNotifier<double>(0.0);
  double _lastRealElapsed = 0.0;
  late final AnimationController _glowController;
  late final List<_LineConfig> _lines;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _lines = List.generate(3, (_) => _LineConfig.random(rng));

    // Use a Ticker instead of AnimationController.repeat() so that driftT
    // grows continuously — no reset, no wrap — eliminating the periodic jump
    // that occurred when AnimationController looped back to 0.
    // Accumulate effective time each frame scaled by the current search speed.
    // This avoids the jump that occurs when multiplying a large driftT by a
    // changing factor — here the speed blends smoothly frame by frame.
    _ticker = createTicker((elapsed) {
      final real = elapsed.inMilliseconds / 1000.0;
      final dt = real - _lastRealElapsed;
      _lastRealElapsed = real;
      final speed = lerpDouble(1.0, 1.5, _glowController.value)!;
      _elapsedNotifier.value += dt * speed;
    })..start();

    // Handles the idle → searching transition envelope (0.0 to 1.0).
    // Per-line glow oscillation is computed independently in the painter.
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    if (widget.isSearching) {
      _glowController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(OracleLinesAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSearching != oldWidget.isSearching) {
      if (widget.isSearching) {
        _glowController.forward();
      } else {
        _glowController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _elapsedNotifier.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery directly so centerX in the painter equals the true
    // horizontal centre of the screen, regardless of parent widget constraints.
    final screenWidth = MediaQuery.of(context).size.width;
    final baseHeight = MediaQuery.of(context).size.height * 0.225;

    // Extra vertical space so the blur can bleed beyond the bar bounds without
    // being clipped by the SizedBox. The painter compensates because
    // size.height = baseHeight + glowBleed * 2, so size.height / 2 naturally
    // lands at the visual center of the bars.
    const glowBleed = 60.0;

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: Listenable.merge([_elapsedNotifier, _glowController]),
        builder: (context, _) {
          return SizedBox(
            width: screenWidth,
            height: baseHeight + glowBleed * 2,
            child: CustomPaint(
              painter: _OracleLinesPainter(
                lines: _lines,
                driftT: _elapsedNotifier.value,
                glowEnvelope: _glowController.value,
                baseHeight: baseHeight,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LineConfig {
  // Drift parameters (sinusoidal position offset)
  final double periodX;
  final double periodY;
  final double phaseX;
  final double phaseY;
  final double ampX;
  final double ampY;

  // Independent glow oscillation parameters (active in both states)
  final double glowPeriod;
  final double glowPhase;

  // Color cycle offset (0.0–1.0): distributes each line at a different point
  // in the shared color cycle so bars show distinct hues simultaneously.
  final double colorPhase;

  const _LineConfig({
    required this.periodX,
    required this.periodY,
    required this.phaseX,
    required this.phaseY,
    required this.ampX,
    required this.ampY,
    required this.glowPeriod,
    required this.glowPhase,
    required this.colorPhase,
  });

  static _LineConfig random(Random rng) {
    return _LineConfig(
      // Very subtle drift — lines are mostly static
      periodX: 3.0 + rng.nextDouble() * 4.0,
      periodY: 3.0 + rng.nextDouble() * 4.0,
      phaseX: rng.nextDouble() * 2 * pi,
      phaseY: rng.nextDouble() * 2 * pi,
      ampX: 0.8 + rng.nextDouble() * 1.2,
      ampY: 0.8 + rng.nextDouble() * 1.2,
      // Random glow oscillation per line — independent of the other lines
      glowPeriod: 1.2 + rng.nextDouble() * 1.8,
      glowPhase: rng.nextDouble() * 2 * pi,
      colorPhase: rng.nextDouble(),
    );
  }
}

class _OracleLinesPainter extends CustomPainter {
  final List<_LineConfig> lines;
  final double driftT;
  final double glowEnvelope;
  final double baseHeight;

  // Center line is tallest and widest; sides differ from each other
  static const List<double> _heightFactors = [0.82, 1.0, 0.88];
  static const List<double> _lineWidths = [10.0, 12.0, 10.0];
  static const double _lineSpacing = 34.0;

  // Colors to cycle through — sourced from the app's design tokens.
  // Each bar starts at a different phase so they show distinct hues at once.
  static const List<Color> _cycleColors = [
    AppColors.accent,
    AppColors.badgeMedia,
    AppColors.badgeBook,
    AppColors.badgeGame,
  ];

  // Duration (seconds) for one full color cycle per bar.
  static const double _colorCyclePeriod = 14.0;

  _OracleLinesPainter({
    required this.lines,
    required this.driftT,
    required this.glowEnvelope,
    required this.baseHeight,
  });

  /// Smoothly interpolates through [_cycleColors] using [effectiveDriftT] and a
  /// per-line [colorPhase] offset so each bar cycles independently.
  Color _lineGlowColor(double effectiveDriftT, double colorPhase) {
    final n = _cycleColors.length;
    final pos = ((effectiveDriftT / _colorCyclePeriod + colorPhase) % 1.0) * n;
    final from = _cycleColors[pos.floor() % n];
    final to = _cycleColors[(pos.floor() + 1) % n];
    return Color.lerp(from, to, pos - pos.floor())!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // xOffsets declared as local alias for readability; static const avoids
    // allocating a list every frame.
    const xOffsets = [-_lineSpacing, 0.0, _lineSpacing];

    for (int i = 0; i < lines.length; i++) {
      final cfg = lines[i];
      final lineWidth = _lineWidths[i];
      final lineHeight = baseHeight * _heightFactors[i];

      final xOff = cfg.ampX * sin(2 * pi * driftT / cfg.periodX + cfg.phaseX);
      final yOff = cfg.ampY * sin(2 * pi * driftT / cfg.periodY + cfg.phaseY);

      // Per-line glow oscillation (0.0 → 1.0), independent between lines
      final perLineGlow =
          sin(2 * pi * driftT / cfg.glowPeriod + cfg.glowPhase) * 0.5 + 0.5;

      // Bars pulse between 100% and 105–110% of their base size while searching.
      // In idle the scale stays at 1.0; glowEnvelope blends in the effect.
      final sizeScale = lerpDouble(
        1.0,
        1.05 + perLineGlow * 0.05,
        glowEnvelope,
      )!;
      final scaledWidth = lineWidth * sizeScale;
      final scaledHeight = lineHeight * sizeScale;

      final left = centerX + xOffsets[i] - scaledWidth / 2 + xOff;
      final top = centerY - scaledHeight / 2 + yOff;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scaledWidth, scaledHeight),
        const Radius.circular(3),
      );

      // Idle: punchy glow with clear per-line pulse variation.
      // Searching: fully saturated, each line blazes at its own pace.
      final idleBlur = 20.0 + perLineGlow * 10.0; // [20 → 30]
      final idleAlpha = 0.45 + perLineGlow * 0.55; // [0.45 → 1.0]
      final searchBlur = 16.0 + perLineGlow * 14.0; // [16 → 30]
      final searchAlpha = 0.80 + perLineGlow * 0.20; // [0.80 → 1.0]

      final blurRadius = lerpDouble(idleBlur, searchBlur, glowEnvelope)!;
      final glowAlpha = lerpDouble(idleAlpha, searchAlpha, glowEnvelope)!;

      // Idle → white glow; searching → app-palette color cycle.
      final glowColor = Color.lerp(
        Colors.white,
        _lineGlowColor(driftT, cfg.colorPhase),
        glowEnvelope,
      )!;

      // Outer glow — wide diffuse halo
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = glowColor.withValues(alpha: glowAlpha * 0.6)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius),
      );

      // Inner glow — tight bright ring right around the bar
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = glowColor.withValues(alpha: glowAlpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius * 0.3),
      );

      // Core layer (crisp white bar)
      canvas.drawRRect(
        rrect,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OracleLinesPainter oldDelegate) =>
      oldDelegate.driftT != driftT ||
      oldDelegate.glowEnvelope != glowEnvelope ||
      oldDelegate.baseHeight != baseHeight;
}
