import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../messages/view/messages_view.dart';
import '../controller/main_nav_controller.dart';
import '../../matching/view/matching_view.dart';
import '../../audio_room/view/audio_room_view.dart';
import '../../profile/view/profile_view.dart';

class MainNavView extends StatelessWidget {
  final MainNavController controller = Get.put(MainNavController());

  MainNavView({super.key});

  @override
  Widget build(BuildContext context) {
    // 4টি স্ক্রিন (ইনডেক্স অনুযায়ী)
    final List<Widget> pages = [
      MatchingView(),       // Index 0
      AudioRoomView(),      // Index 1
      MessagesView(),       // Index 2
      ProfileView(),        // Index 3
    ];

    return Scaffold(
      extendBody: true, // বডি যেন নেভিগেশন বারের নিচ পর্যন্ত যায়
      backgroundColor: Colors.transparent,

      // 🔥 BUG FIXED: সাধারণ IndexedStack এর বদলে LazyIndexedStack ব্যবহার করা হলো।
      // এখন ৪টি পেজ একসাথে লোড হয়ে ফোন হ্যাং করবে না!
      body: Obx(() => _LazyIndexedStack(
        index: controller.currentIndex.value,
        children: pages,
      )),

      // Floating Premium Navigation Bar
      bottomNavigationBar: _buildFloatingNavBar(context),
    );
  }

  // 💎 Premium Floating Glassmorphism Nav Bar
  Widget _buildFloatingNavBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15), // Floating Effect
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              height: 75,
              decoration: BoxDecoration(
                color: const Color(0xFF0A0514).withOpacity(0.65), // Deep translucent black/purple
                borderRadius: BorderRadius.circular(35),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ✨ Subtle Neon Orbs inside the Nav Bar
                  Positioned(
                    left: -20,
                    top: -20,
                    child: _buildNavOrb(const Color(0xFF00F0FF), 80),
                  ),
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: _buildNavOrb(const Color(0xFFFF007A), 100),
                  ),

                  // 🔘 Navigation Items
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _buildNavItem(0, FontAwesomeIcons.satelliteDish, 'Match')),
                        Expanded(child: _buildNavItem(1, FontAwesomeIcons.headset, 'Adda')),
                        Expanded(child: _buildNavItem(2, FontAwesomeIcons.commentDots, 'Chats')),
                        Expanded(child: _buildNavItem(3, FontAwesomeIcons.userAstronaut, 'Profile')),
                      ],
                    )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(color: Colors.transparent),
      ),
    );
  }

  // 💎 Premium Nav Item with Glowing Pill Effect
  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = controller.currentIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changePage(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutExpo,
            height: isSelected ? 55 : 45,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: isSelected
                ? BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00F0FF).withOpacity(0.3), // Cyan glow
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                )
              ],
            )
                : const BoxDecoration(color: Colors.transparent),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.white54,
                  size: isSelected ? 22 : 18,
                ),
                if (isSelected) const SizedBox(height: 4),
                if (isSelected)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =======================================================
// 🔥 LazyIndexedStack (THE ULTIMATE PERFORMANCE SAVER)
// =======================================================
class _LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const _LazyIndexedStack({
    required this.index,
    required this.children,
  });

  @override
  _LazyIndexedStackState createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<_LazyIndexedStack> {
  late List<bool> _activatedList;

  @override
  void initState() {
    super.initState();
    // প্রথমে সবগুলো পেজ 'False' (unloaded) থাকবে
    _activatedList = List<bool>.filled(widget.children.length, false);
    // শুধু প্রথম যে পেজটা ওপেন হবে, সেটা 'True' হবে
    _activatedList[widget.index] = true;
  }

  @override
  void didUpdateWidget(_LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ইউজার নতুন কোনো ট্যাবে ক্লিক করলে সেটাকে 'True' করে দেবে (মেমোরিতে লোড করবে)
    if (oldWidget.index != widget.index) {
      _activatedList[widget.index] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: List.generate(widget.children.length, (i) {
        // যদি পেজটি এখনো ভিজিট করা না হয়, তবে SizedBox (0 memory) দেখাবে।
        if (!_activatedList[i]) {
          return const SizedBox.shrink();
        }
        return widget.children[i];
      }),
    );
  }
}