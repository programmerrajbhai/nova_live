import 'package:flutter/material.dart';

class PremiumBackground extends StatelessWidget {
  final Widget child;

  const PremiumBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF05020A), // Deepest black base
      body: Stack(
        children: [
          // 🔥 1. Rich Deep Gradient Base
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2B0B30), // Deep ruby/purple
                  Color(0xFF170815), // Midnight dark
                  Color(0xFF09040B), // Pure luxury black
                  Color(0xFF05020A), // Abyss
                ],
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // 🔥 2. Vibrant Neon Orbs (Cheaper than Blur, but looks awesome)
          // Top Right - Neon Cyan/Blue
          Positioned(
            top: -size.height * 0.1,
            right: -size.width * 0.2,
            child: _buildGlowOrb(const Color(0xFF00F0FF), size.width * 0.7, 0.12),
          ),

          // Bottom Left - Hot Pink/Magenta
          Positioned(
            bottom: -size.height * 0.1,
            left: -size.width * 0.2,
            child: _buildGlowOrb(const Color(0xFFFF007A), size.width * 0.8, 0.15),
          ),

          // Center Left - Deep Violet
          Positioned(
            top: size.height * 0.3,
            left: -size.width * 0.3,
            child: _buildGlowOrb(const Color(0xFF8A2BE2), size.width * 0.6, 0.15),
          ),

          // 🔥 3. Diagonal Luxury Shine (Glass Reflection Effect - 0 GPU cost)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.06),
                      Colors.white.withOpacity(0.01),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.white.withOpacity(0.03),
                    ],
                    stops: const [0.0, 0.25, 0.25, 0.8, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 🔥 4. Subtle Vignette (Darkens corners to focus on the center content)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🔥 5. Real Content
          SafeArea(
            child: child,
          ),
        ],
      ),
    );
  }

  // 💡 Native shadow blur is extremely fast and creates a beautiful neon glow
  Widget _buildGlowOrb(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(opacity),
            blurRadius: 180, // Massive blur for smooth blending
            spreadRadius: 60,
          ),
        ],
      ),
    );
  }
}