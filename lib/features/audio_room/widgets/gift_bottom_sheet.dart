import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/active_room_controller.dart';

class GiftBottomSheet {
  static void show(BuildContext context, ActiveRoomController roomController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: Colors.pinkAccent.withOpacity(0.5), width: 1),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Send a Premium Gift 🎁', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildGiftItem("Rose", 10, Icons.local_florist, Colors.redAccent, roomController),
                    _buildGiftItem("Heart", 50, Icons.favorite, Colors.pinkAccent, roomController),
                    _buildGiftItem("Diamond", 100, Icons.diamond, Colors.cyanAccent, roomController),
                    _buildGiftItem("Crown", 500, Icons.workspace_premium, Colors.amberAccent, roomController),
                    _buildGiftItem("Rocket", 1000, Icons.rocket_launch, Colors.deepOrangeAccent, roomController),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildGiftItem(String name, int cost, IconData icon, Color color, ActiveRoomController controller) {
    return GestureDetector(
      onTap: () {
        Get.back(); // ডায়ালগ বন্ধ করবে
        controller.sendGift(name, cost, icon, color); // রিয়েল কন্ট্রোলারে গিফট সেন্ড হবে
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.6), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text('💎 $cost', style: const TextStyle(color: Colors.yellowAccent, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}