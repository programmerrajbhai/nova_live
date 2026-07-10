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
    // 4টি স্ক্রিন (ইনডেক্স অনুযায়ী)
    final List<Widget> pages = [
      MatchingView(),       // Index 0
      AudioRoomView(),      // Index 1
      MessagesView(),       // Index 2
      ProfileView(),        // Index 3
    ];

    return Scaffold(
      extendBody: true, // বডি যেন নেভিগেশন বারের নিচ পর্যন্ত যায় (গ্লাস ইফেক্টের জন্য)
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: pages,
      )),
      bottomNavigationBar: _buildCustomNavBar(context), // context পাস করা হলো
    );
  }

  // 🔥 সম্পূর্ণ কাস্টম, রেস্পন্সিভ এবং ১০০% ফিক্সড বটম নেভিগেশন বার
  Widget _buildCustomNavBar(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Container(
        color: const Color(0xFF10092B), // স্ক্রিনশটের মতো ডার্ক পার্পল/নেভি ব্লু বেইজ
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ✨ ব্যাকগ্রাউন্ডের গ্লোয়িং ইফেক্ট (Cyan & Blue Orbs)
            Positioned(
              left: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyanAccent.withOpacity(0.15),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.15),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            // 🔘 নেভিগেশন আইটেমগুলো
            SafeArea(
              bottom: true, // আইফোনের নিচের হোম বারের জন্য সেফ জোন
              child: Container(
                height: 75, // 🔥 এখানে ফিক্সড হাইট দেওয়া হলো, যাতে স্ক্রিন লেআউট ক্র্যাশ না করে
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Expanded উইজেট আইটেমগুলোকে সমান ৪ ভাগে ভাগ করে ওভারফ্লো ঠেকাবে
                    Expanded(child: _buildNavItem(0, FontAwesomeIcons.satelliteDish, 'Match')),
                    Expanded(child: _buildNavItem(1, FontAwesomeIcons.headset, 'Adda')),
                    Expanded(child: _buildNavItem(2, FontAwesomeIcons.commentDots, 'Chats')),
                    Expanded(child: _buildNavItem(3, FontAwesomeIcons.userAstronaut, 'Profile')),
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💎 গ্লাসমরফিজম স্টাইলের প্রতিটি আইটেম (Responsive)
  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = controller.currentIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changePage(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent, // পুরো বক্স ক্লিকেবল করার জন্য
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isSelected ? 60 : 50, // সিলেক্ট হলে বক্স একটু বড় হবে
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: isSelected
                ? BoxDecoration(
              color: Colors.white.withOpacity(0.1), // গ্লাসের মতো স্বচ্ছতা
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.25), // স্ক্রিনশটের মতো ব্লু গ্লো
                  blurRadius: 15,
                  spreadRadius: 1,
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
                  size: isSelected ? 20 : 18,
                ),
                const SizedBox(height: 4),
                // FittedBox টেক্সট বড় হলে ফেটে যাওয়া বা ওভারফ্লো হওয়া থেকে বাঁচাবে
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white54,
                      fontSize: isSelected ? 12 : 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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