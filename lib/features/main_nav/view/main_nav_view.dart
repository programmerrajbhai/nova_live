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
    // এখানে অবশ্যই ৪টি স্ক্রিন থাকতে হবে, কারণ নিচে ৪টি নেভিগেশন আইটেম আছে।
    final List<Widget> pages = [
      MatchingView(),       // Index 0
      AudioRoomView(),      // Index 1
      MessagesView(), // Index 2
      ProfileView(),        // Index 3
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: pages,
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changePage,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.satelliteDish),
            label: 'Match',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.headset),
            label: 'Adda',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.commentDots),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.userAstronaut),
            label: 'Profile',
          ),
        ],
      )),
    );
  }
}