import 'dart:math';
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

class OracleLinesAnimation extends StatefulWidget {
  final bool isSearching;

  const OracleLinesAnimation({super.key, required this.isSearching});

  @override
  State<OracleLinesAnimation> createState() => _OracleLinesAnimationState();
}

class _OracleLinesAnimationState extends State<OracleLinesAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _driftController;
  late final AnimationController _glowController;
  late final List<_LineConfig> _lines;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _lines = List.generate(3, (_) => _LineConfig.random(rng));

    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

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
    _driftController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery directly so centerX in the painter equals the true
    // horizontal centre of the screen, regardless of parent widget constraints.
    final screenWidth = MediaQuery.of(context).size.width;
    final baseHeight = MediaQuery.of(context).size.height * 0.225;

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: Listenable.merge([_driftController, _glowController]),
        builder: (context, _) {
          return SizedBox(
            width: screenWidth,
            height: baseHeight,
            child: CustomPaint(
              painter: _OracleLinesPainter(
                lines: _lines,
                driftT: _driftController.value * 10.0,
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

  const _LineConfig({
    required this.periodX,
    required this.periodY,
    required this.phaseX,
    required this.phaseY,
    required this.ampX,
    required this.ampY,
    required this.glowPeriod,
    required this.glowPhase,
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

  _OracleLinesPainter({
    required this.lines,
    required this.driftT,
    required this.glowEnvelope,
    required this.baseHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final xOffsets = [-_lineSpacing, 0.0, _lineSpacing];

    for (int i = 0; i < lines.length; i++) {
      final cfg = lines[i];
      final lineWidth = _lineWidths[i];
      final lineHeight = baseHeight * _heightFactors[i];

      final xOff = cfg.ampX * sin(2 * pi * driftT / cfg.periodX + cfg.phaseX);
      final yOff = cfg.ampY * sin(2 * pi * driftT / cfg.periodY + cfg.phaseY);

      final left = centerX + xOffsets[i] - lineWidth / 2 + xOff;
      final top = centerY - lineHeight / 2 + yOff;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, lineWidth, lineHeight),
        const Radius.circular(3),
      );

      // Per-line glow oscillation (0.0 → 1.0), independent between lines
      final perLineGlow =
          sin(2 * pi * driftT / cfg.glowPeriod + cfg.glowPhase) * 0.5 + 0.5;

      // Idle: visible soft glow with subtle per-line variation.
      // Searching: more intense, each line oscillates at its own pace.
      final idleBlur = 5.0 + perLineGlow * 4.0; // [5 → 9]
      final idleAlpha = 0.22 + perLineGlow * 0.13; // [0.22 → 0.35]
      final searchBlur = 8.0 + perLineGlow * 8.0; // [8 → 16]
      final searchAlpha = 0.42 + perLineGlow * 0.33; // [0.42 → 0.75]

      final blurRadius = lerpDouble(idleBlur, searchBlur, glowEnvelope)!;
      final glowAlpha = lerpDouble(idleAlpha, searchAlpha, glowEnvelope)!;

      // Glow layer
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = Colors.white.withValues(alpha: glowAlpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius),
      );

      // Core layer (crisp white line)
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
