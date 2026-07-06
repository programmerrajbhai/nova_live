import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../controller/active_room_controller.dart';

class ActiveAudioRoomView extends StatefulWidget {
  final String roomId;
  final String roomName;
  final bool isHost;
  final String userId;
  final String userName;
  final String userAvatar;

  const ActiveAudioRoomView({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.isHost,
    required this.userId,
    required this.userName,
    required this.userAvatar,
  });

  @override
  State<ActiveAudioRoomView> createState() => _ActiveAudioRoomViewState();
}

class _ActiveAudioRoomViewState extends State<ActiveAudioRoomView> {
  final ActiveRoomController roomController = Get.put(ActiveRoomController());
  final TextEditingController chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ZegoUIKit().installPlugins([ZegoUIKitSignalingPlugin()]);
  }

  @override
  void dispose() {
    chatController.dispose();
    if (widget.isHost) {
      FirebaseFirestore.instance.collection('live_audio_rooms').doc(widget.roomId).delete();
    }
    super.dispose();
  }

  // 💬 রিয়েল মেসেজ সেন্ড ফাংশন
  void _sendMessage() {
    if (chatController.text.trim().isNotEmpty) {
      ZegoUIKit().sendInRoomMessage(chatController.text.trim());
      chatController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  // 🚪 লিভ কনফার্মেশন ডায়ালগ
  void _showLeaveDialog() {
    Get.defaultDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      title: 'Leave Room?',
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      content: const Text('Are you sure you want to leave this audio room?', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
      cancel: TextButton(onPressed: () => Get.back(), child: const Text('Stay', style: TextStyle(color: Colors.cyanAccent))),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        onPressed: () {
          Get.back();
          Get.back();
        },
        child: const Text('Leave', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String safeUserId = widget.userId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (safeUserId.isEmpty) safeUserId = "user_${DateTime.now().millisecondsSinceEpoch}";

    ZegoUIKitPrebuiltLiveAudioRoomConfig config = widget.isHost
        ? ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
        : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience();

    config.bottomMenuBarConfig.hostButtons = [];
    config.bottomMenuBarConfig.speakerButtons = [];
    config.bottomMenuBarConfig.audienceButtons = [];
    config.bottomMenuBarConfig.showInRoomMessageButton = false;
    config.topMenuBarConfig.buttons = [];

    config.background = Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D0B14),
        image: DecorationImage(
          image: NetworkImage('https://i.pinimg.com/originals/52/bd/2b/52bd2b8c56cc6ce00d021c3b16868846.jpg'),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
    );

    // 🪑 সিট লেআউট: ৩ লাইন, প্রতি লাইনে ৪ জন = মোট ১২ সিট
    config.seat.layout = ZegoLiveAudioRoomLayoutConfig(
      rowConfigs: [
        ZegoLiveAudioRoomLayoutRowConfig(count: 4, alignment: ZegoLiveAudioRoomLayoutAlignment.spaceAround),
        ZegoLiveAudioRoomLayoutRowConfig(count: 4, alignment: ZegoLiveAudioRoomLayoutAlignment.spaceAround),
        ZegoLiveAudioRoomLayoutRowConfig(count: 4, alignment: ZegoLiveAudioRoomLayoutAlignment.spaceAround),
      ],
    );

    if (widget.isHost) config.seat.hostIndexes = [0];

    // 🖼️ কাস্টম সিট বিল্ডার (লক এবং বসার সমস্যা ১০০% ফিক্সড)
    config.seat.avatarBuilder = (BuildContext context, Size size, ZegoUIKitUser? user, Map<String, dynamic> extraInfo) {

      // 🔴 যদি সিট ফাঁকা থাকে
      if (user == null || user.id.isEmpty) {
        // 🔥 ম্যাজিক ফিক্স: এখানে কোনো GestureDetector দেওয়া হয়নি!
        // এর ফলে Zego-র ডিফল্ট ক্লিক কাজ করবে। হোস্ট ক্লিক করলে লক মেনু আসবে, অডিয়েন্স ক্লিক করলে বসতে পারবে।
        return Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white12, width: 1.5)
          ),
          child: const Center(child: Icon(Icons.add, color: Colors.white38, size: 24)),
        );
      }

      // 🟢 যদি সিটে ইউজার বসা থাকে
      String firstLetter = user.name.trim().isNotEmpty ? user.name.trim().substring(0, 1).toUpperCase() : 'U';
      bool isHostUser = widget.isHost && user.id == safeUserId;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // নিজের প্রোফাইল ছাড়া বাকি সবার প্রোফাইল মেনু ওপেন হবে
          if (user.id != safeUserId) {
            UserProfileSheet.show(context: context, clickedUser: user, isHost: widget.isHost, roomId: widget.roomId);
          }
        },
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isHostUser ? Colors.purpleAccent : Colors.cyanAccent.withOpacity(0.5), width: 2),
                boxShadow: [BoxShadow(color: isHostUser ? Colors.purpleAccent.withOpacity(0.4) : Colors.transparent, blurRadius: 15)],
              ),
              child: CircleAvatar(
                radius: size.width / 2,
                backgroundColor: const Color(0xFF1A1A2E),
                backgroundImage: (user.id == safeUserId && widget.userAvatar.isNotEmpty) ? NetworkImage(widget.userAvatar) : null,
                child: (user.id != safeUserId || widget.userAvatar.isEmpty)
                    ? Text(firstLetter, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))
                    : null,
              ),
            ),
            Positioned(
              bottom: 0, right: -5,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.purpleAccent, shape: BoxShape.circle, border: Border.all(color: const Color(0xFF0D0B14), width: 2)),
                child: const Icon(Icons.mic, color: Colors.white, size: 10),
              ),
            ),
          ],
        ),
      );
    };

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0B14),
        body: Stack(
          children: [
            // ১. মূল অডিও রুম উইজেট
            ZegoUIKitPrebuiltLiveAudioRoom(
              appID: 358538422,
              appSign: '7e4ad77a5ad88a14bdbfbda739b67e9de336d5c91aa0b00672c22eecd96823fa',
              userID: safeUserId,
              userName: widget.userName.isEmpty ? "Nova User" : widget.userName,
              roomID: widget.roomId,
              config: config,
            ),

            // ২. কাস্টম টপ বার
            Positioned(
              top: 15, left: 15, right: 15,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white24, width: 1)),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 18, backgroundImage: widget.userAvatar.isNotEmpty ? NetworkImage(widget.userAvatar) : null),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.roomName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                Text('ID: ${widget.roomId.substring(0, 5)}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.power_settings_new, color: Colors.redAccent), onPressed: _showLeaveDialog),
                ],
              ),
            ),

            // ৩. কাস্টম বটম বার (রিয়েল চ্যাট ও অ্যাকশন বাটন)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), border: const Border(top: BorderSide(color: Colors.white12, width: 1))),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(25)),
                            child: TextField(
                              controller: chatController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: const TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.send, color: Colors.cyanAccent),
                                  onPressed: _sendMessage,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Obx(() => GestureDetector(
                          onTap: () {
                            roomController.toggleMute();
                            Get.snackbar('Microphone', roomController.isMuted.value ? 'Mic is Muted 🔇' : 'Mic is On 🎤', backgroundColor: Colors.black87, colorText: Colors.white, duration: const Duration(seconds: 1));
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.white10,
                            child: Icon(roomController.isMuted.value ? Icons.mic_off : Icons.mic, color: roomController.isMuted.value ? Colors.redAccent : Colors.cyanAccent),
                          ),
                        )),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => GiftBottomSheet.show(context, roomController),
                          child: const CircleAvatar(
                            backgroundColor: Colors.white10,
                            child: Icon(Icons.card_giftcard, color: Colors.purpleAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ৪. গিফট অ্যানিমেশন ওভারলে
            Obx(() {
              if (roomController.showGiftAnimation.value) {
                return Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.5, end: 1.5),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: Icon(roomController.currentGiftIcon.value, color: roomController.currentGiftColor.value, size: 150, shadows: [Shadow(color: roomController.currentGiftColor.value, blurRadius: 40)]),
                      );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 🎁 গিফট বটম শিট ক্লাস (একই ফাইলে)
// ==========================================
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
        Get.back();
        controller.sendGift(name, cost, icon, color);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.6), width: 1.5)),
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

// ==========================================
// 👤 ইউজার প্রোফাইল শিট ক্লাস (একই ফাইলে)
// ==========================================
class UserProfileSheet {
  static void show({
    required BuildContext context,
    required ZegoUIKitUser clickedUser,
    required bool isHost,
    required String roomId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF141E30), Color(0xFF243B55)]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
            border: Border.all(color: Colors.purpleAccent.withOpacity(0.3), width: 1.5),
          ),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 25),
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF1A1A2E),
                child: Text(
                  clickedUser.name.isNotEmpty ? clickedUser.name.substring(0, 1).toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 40, color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              Text(clickedUser.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text('ID: ${clickedUser.id}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Get.back();
                  Get.snackbar('Profile', 'Opening ${clickedUser.name}\'s profile...', backgroundColor: Colors.cyanAccent, colorText: Colors.black);
                },
                child: const Text('View Full Profile', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              if (isHost) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton('Kick', Icons.output, Colors.orangeAccent, () {
                      Get.back();
                      Get.snackbar('Kicked', 'User has been kicked.', backgroundColor: Colors.orangeAccent, colorText: Colors.white);
                    }),
                    _buildActionButton('Ban', Icons.block, Colors.redAccent, () async {
                      Get.back();
                      await FirebaseFirestore.instance.collection('banned_users').doc(roomId).collection('users').doc(clickedUser.id).set({'banned': true});
                      Get.snackbar('Banned 🚫', '${clickedUser.name} is permanently banned.', backgroundColor: Colors.redAccent, colorText: Colors.white);
                    }),
                  ],
                )
              ] else ...[
                _buildActionButton('Report User', Icons.report_problem, Colors.orangeAccent, () {
                  Get.back();
                  Get.snackbar('Reported', 'User reported successfully.', backgroundColor: Colors.orangeAccent, colorText: Colors.white);
                }),
              ]
            ],
          ),
        );
      },
    );
  }

  static Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(0.5))),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}