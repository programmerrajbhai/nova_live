import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nova_live/core/widgets/premium_background.dart';

import '../controller/matching_controller.dart';

class MatchingView extends StatelessWidget {
  final MatchingController controller = Get.put(MatchingController());

  MatchingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF5DAE),
                    Color(0xFFE948A0),
                    Color(0xFF8A35FF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE948A0).withOpacity(0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.videocam_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Nova Live',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () => _showInfoSheet(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF170815).withOpacity(0.72),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white.withOpacity(0.88),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: PremiumBackground(
        child: Obx(
              () {
            final bool isSearching = controller.isSearching.value;

            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 110, 22, 34),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Status pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF170815).withOpacity(0.62),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.22),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSearching
                                  ? const Color(0xFF24FF9D)
                                  : const Color(0xFFFF5DAE),
                              boxShadow: [
                                BoxShadow(
                                  color: isSearching
                                      ? const Color(0xFF24FF9D).withOpacity(0.7)
                                      : const Color(0xFFFF5DAE).withOpacity(0.6),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 9),
                          Text(
                            isSearching
                                ? 'Searching for a live match...'
                                : 'Random live match ready',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.88),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Real working info card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF170815).withOpacity(0.72),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.075),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.26),
                                blurRadius: 28,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFFE948A0)
                                              .withOpacity(0.28),
                                          const Color(0xFF8A35FF)
                                              .withOpacity(0.24),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.08),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.shuffle_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Random Match Mode',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'No fake filter, no fake promise. Just tap and start searching.',
                                          style: TextStyle(
                                            color:
                                            Colors.white.withOpacity(0.48),
                                            fontSize: 12.3,
                                            fontWeight: FontWeight.w500,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: _miniStepCard(
                                      icon: Icons.touch_app_rounded,
                                      title: 'Tap',
                                      subtitle: 'Start',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _miniStepCard(
                                      icon: Icons.radar_rounded,
                                      title: 'Search',
                                      subtitle: 'Match',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _miniStepCard(
                                      icon: Icons.videocam_rounded,
                                      title: 'Live',
                                      subtitle: 'Connect',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 42),

                    // Main matching button
                    GestureDetector(
                      onTap: controller.toggleSearch,
                      child: AnimatedScale(
                        scale: isSearching ? 1.04 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        child: SizedBox(
                          width: 230,
                          height: 230,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: isSearching ? 225 : 195,
                                height: isSearching ? 225 : 195,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFE948A0).withOpacity(
                                    isSearching ? 0.10 : 0.055,
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFFFF5DAE).withOpacity(
                                      isSearching ? 0.26 : 0.12,
                                    ),
                                  ),
                                ),
                              ),

                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                width: isSearching ? 195 : 168,
                                height: isSearching ? 195 : 168,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF8A35FF).withOpacity(
                                    isSearching ? 0.13 : 0.07,
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFF8A35FF).withOpacity(
                                      isSearching ? 0.25 : 0.13,
                                    ),
                                  ),
                                ),
                              ),

                              Container(
                                width: 156,
                                height: 156,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFFFF5DAE),
                                      Color(0xFFE948A0),
                                      Color(0xFF8A35FF),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.18),
                                    width: 1.4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFE948A0)
                                          .withOpacity(
                                        isSearching ? 0.62 : 0.42,
                                      ),
                                      blurRadius: isSearching ? 45 : 30,
                                      spreadRadius: isSearching ? 7 : 2,
                                      offset: const Offset(0, 14),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF8A35FF)
                                          .withOpacity(
                                        isSearching ? 0.42 : 0.26,
                                      ),
                                      blurRadius: isSearching ? 42 : 26,
                                      offset: const Offset(0, -8),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                      top: 18,
                                      left: 28,
                                      child: Container(
                                        width: 54,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.20),
                                          borderRadius:
                                          BorderRadius.circular(100),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                              Colors.white.withOpacity(0.12),
                                              blurRadius: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isSearching
                                              ? Icons.radar_rounded
                                              : Icons.videocam_rounded,
                                          color: Colors.white,
                                          size: 36,
                                          shadows: [
                                            Shadow(
                                              color:
                                              Colors.black.withOpacity(0.35),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          isSearching
                                              ? 'Searching...'
                                              : 'Tap to\nMatch',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 19,
                                            height: 1.1,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 34),

                    Row(
                      children: [
                        Expanded(
                          child: _infoCard(
                            icon: Icons.shuffle_rounded,
                            title: 'Random',
                            subtitle: 'Simple mode',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoCard(
                            icon: Icons.flash_on_rounded,
                            title: 'Quick',
                            subtitle: 'Easy start',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _infoCard(
                            icon: Icons.video_call_rounded,
                            title: 'Live',
                            subtitle: 'Video match',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (_) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              decoration: BoxDecoration(
                color: const Color(0xFF170815).withOpacity(0.94),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'About Random Match',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This screen uses random matching only. No Global or Local filter is shown because those features are not active in the app logic.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.58),
                        fontSize: 13.5,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _sheetPoint(
                      icon: Icons.check_circle_rounded,
                      text: 'Tap the match button to start searching.',
                    ),
                    const SizedBox(height: 12),
                    _sheetPoint(
                      icon: Icons.check_circle_rounded,
                      text: 'Tap again to stop searching.',
                    ),
                    const SizedBox(height: 12),
                    _sheetPoint(
                      icon: Icons.check_circle_rounded,
                      text: 'Only real available app features are displayed.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sheetPoint({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFFF5DAE),
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.74),
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniStepCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Colors.white.withOpacity(0.065),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFF5DAE),
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.42),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF170815).withOpacity(0.58),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.07),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: const Color(0xFFFF5DAE),
                size: 22,
              ),
              const SizedBox(height: 7),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.42),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}