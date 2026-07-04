import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/active_room_controller.dart';
import '../model/audio_room_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ActiveAudioRoomView extends StatelessWidget {
  final AudioRoom room;
  final ActiveRoomController controller = Get.put(ActiveRoomController());

  ActiveAudioRoomView({super.key, required this.room});

  // গিফট মেনু (Bottom Sheet) দেখানোর মেথড
  void _showGiftMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Send Gift', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  // ইউজারের বর্তমান ব্যালেন্স দেখানো
                  Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.orangeAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        const Icon(FontAwesomeIcons.coins, color: Colors.orangeAccent, size: 14),
                        const SizedBox(width: 5),
                        Text('${controller.profileController.myCoins.value}', style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: [
                    _buildGiftItem('Rose', 10, FontAwesomeIcons.pagelines, Colors.redAccent),
                    _buildGiftItem('Heart', 50, FontAwesomeIcons.solidHeart, Colors.pinkAccent),
                    _buildGiftItem('Crown', 100, FontAwesomeIcons.crown, Colors.amberAccent),
                    _buildGiftItem('Diamond', 500, FontAwesomeIcons.gem, Colors.cyanAccent),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // গিফট আইটেম উইজেট
  Widget _buildGiftItem(String name, int cost, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Get.back(); // বটম শিট ক্লোজ
        controller.sendGift(name, cost, icon, color); // গিফট লজিক কল
      },
      child: Container(
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 35),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text(cost.toString(), style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack( // স্ট্যাক ব্যবহার করা হয়েছে যেন অ্যানিমেশন সবার উপরে ভাসে
        children: [
          // মূল UI
          Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 35), onPressed: controller.leaveRoom),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(room.roomName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                          Text('${room.activeUsers} people here', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // স্পিকার গ্রিড
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 20, mainAxisSpacing: 30, childAspectRatio: 0.8,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.primaries[index % Colors.primaries.length].withOpacity(0.3),
                          child: Icon(Icons.person, size: 40, color: Colors.primaries[index % Colors.primaries.length]),
                        ),
                        const SizedBox(height: 8),
                        Text('Speaker ${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    );
                  },
                ),
              ),

              // বটম কন্ট্রোল প্যানেল
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E).withOpacity(0.9),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // লিভ বাটন
                      GestureDetector(
                        onTap: controller.leaveRoom,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(25)),
                          child: const Text('✌️ Leave', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                      ),

                      // মিউট বাটন
                      Obx(() => GestureDetector(
                        onTap: controller.toggleMute,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: controller.isMuted.value ? Colors.white10 : Colors.greenAccent.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(controller.isMuted.value ? Icons.mic_off : Icons.mic, color: controller.isMuted.value ? Colors.grey : Colors.greenAccent),
                        ),
                      )),

                      // গিফট বাটন (নতুন)
                      GestureDetector(
                        onTap: () => _showGiftMenu(context),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Colors.pinkAccent, Colors.orangeAccent]),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.5), blurRadius: 10)],
                          ),
                          child: const Icon(FontAwesomeIcons.gift, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // সেন্ট্রাল গিফট অ্যানিমেশন ওভারলে
          Obx(() {
            if (controller.showGiftAnimation.value) {
              return Center(
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 30, end: 150), // ছোট থেকে বড় হবে
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut, // বাউন্সি ইফেক্ট
                  builder: (_, double size, __) {
                    return Icon(
                      controller.currentGiftIcon.value,
                      color: controller.currentGiftColor.value,
                      size: size,
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink(); // অ্যানিমেশন বন্ধ থাকলে ফাঁকা
          }),
        ],
      ),
    );
  }
}