import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class PremiumBackground extends StatefulWidget {
  final Widget child;

  const PremiumBackground({
    super.key,
    required this.child,
  });

  @override
  State<PremiumBackground> createState() => _PremiumBackgroundState();
}

class _PremiumBackgroundState extends State<PremiumBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // Main premium dark base
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4A173A), // soft wine top
                  Color(0xFF2D1028), // deep plum
                  Color(0xFF170815), // nav bar matching dark
                  Color(0xFF09040B), // luxury black
                ],
                stops: [0.0, 0.32, 0.68, 1.0],
              ),
            ),
          ),

          // Animated premium glowing mesh
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _PremiumBackgroundPainter(
                    progress: _controller.value,
                  ),
                );
              },
            ),
          ),

          // Smooth glass haze layer
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 38, sigmaY: 38),
              child: Container(
                color: const Color(0xFF170815).withOpacity(0.10),
              ),
            ),
          ),

          // Top pink soft shine
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      const Color(0xFF112AFF).withOpacity(0.13),
                      const Color(0xD5112AFF).withOpacity(0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom black premium depth
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF09040B).withOpacity(0.72),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Side vignette for app depth
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.08,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.28),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Premium tiny dust texture
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _PremiumDustPainter(),
              ),
            ),
          ),

          // Real content
          SafeArea(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _PremiumBackgroundPainter extends CustomPainter {
  final double progress;

  _PremiumBackgroundPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * 2 * pi;

    void drawGlow({
      required Offset center,
      required double radius,
      required Color color,
      required double blur,
    }) {
      final paint = Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

      canvas.drawCircle(center, radius, paint);
    }

    // Top right soft pink glow
    drawGlow(
      center: Offset(
        size.width * (0.88 + sin(t * 0.8) * 0.035),
        size.height * (0.10 + cos(t * 0.7) * 0.025),
      ),
      radius: size.width * 0.40,
      color: const Color(0xFF112AFF).withOpacity(0.24),
      blur: 95,
    );

    // Left purple glow
    drawGlow(
      center: Offset(
        size.width * (0.04 + cos(t * 0.6) * 0.035),
        size.height * (0.42 + sin(t * 0.8) * 0.030),
      ),
      radius: size.width * 0.54,
      color: const Color(0xFF8A35FF).withOpacity(0.18),
      blur: 110,
    );

    // Center wine glow
    drawGlow(
      center: Offset(
        size.width * (0.50 + sin(t * 0.5) * 0.025),
        size.height * (0.34 + cos(t * 0.6) * 0.025),
      ),
      radius: size.width * 0.52,
      color: const Color(0xD5112AFF).withOpacity(0.13),
      blur: 120,
    );

    // Bottom pink-purple glow behind bottom nav
    drawGlow(
      center: Offset(
        size.width * (0.52 + cos(t * 0.7) * 0.025),
        size.height * (0.96 + sin(t * 0.8) * 0.020),
      ),
      radius: size.width * 0.58,
      color: const Color(0xFF112AFF).withOpacity(0.20),
      blur: 115,
    );

    // Bottom purple neon glow
    drawGlow(
      center: Offset(
        size.width * (0.82 + sin(t * 0.9) * 0.025),
        size.height * (0.82 + cos(t * 0.7) * 0.020),
      ),
      radius: size.width * 0.42,
      color: const Color(0xD5112AFF).withOpacity(0.16),
      blur: 105,
    );

    // Premium diagonal soft shine
    final shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.070),
          Colors.white.withOpacity(0.018),
          Colors.transparent,
        ],
        stops: const [0.0, 0.36, 1.0],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    final shinePath = Path()
      ..moveTo(size.width * 0.04, 0)
      ..lineTo(size.width * 0.42, 0)
      ..lineTo(size.width * 0.18, size.height)
      ..lineTo(-size.width * 0.20, size.height)
      ..close();

    canvas.drawPath(shinePath, shinePaint);

    // Very soft curved light line
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withOpacity(0.050)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    path.moveTo(0, size.height * 0.25);

    for (double x = 0; x <= size.width; x += 12) {
      final y = size.height * 0.25 +
          sin((x / size.width * 2 * pi) + t) * 12 +
          cos((x / size.width * 4 * pi) + t) * 5;

      path.lineTo(x, y);
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _PremiumBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _PremiumDustPainter extends CustomPainter {
  const _PremiumDustPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(18);

    for (int i = 0; i < 95; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.05 + 0.20;

      final paint = Paint()
        ..color = Colors.white.withOpacity(
          random.nextDouble() * 0.045 + 0.010,
        );

      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}