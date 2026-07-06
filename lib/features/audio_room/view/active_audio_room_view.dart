import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

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

  @override
  void initState() {
    super.initState();
    ZegoUIKit().installPlugins([ZegoUIKitSignalingPlugin()]);
  }

  @override
  void dispose() {
    if (widget.isHost) {
      FirebaseFirestore.instance.collection('live_audio_rooms').doc(widget.roomId).delete();
    }
    super.dispose();
  }

  // 🔥 UGC Policy 1: ইউজারের প্রোফাইলে ক্লিক করলে এই মেনু আসবে
  void _showUserActionMenu(BuildContext context, ZegoUIKitUser clickedUser) {
    if (clickedUser.id == widget.userId) return; // নিজের আইডিতে ক্লিক করলে মেনু আসবে না

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ইউজারের নাম ও ছবি
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white10,
                child: Text(
                  clickedUser.name.isNotEmpty ? clickedUser.name.substring(0, 1).toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 24, color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Text(clickedUser.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // 👁️ সবার জন্য View Profile অপশন
              ListTile(
                leading: const Icon(Icons.person, color: Colors.cyanAccent),
                title: const Text('View Profile', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Get.back();
                  Get.snackbar('Profile', 'Opening ${clickedUser.name}\'s profile...', backgroundColor: Colors.black87, colorText: Colors.white);
                },
              ),

              // 🛡️ হোস্টের জন্য কন্ট্রোল (Kick / Ban)
              if (widget.isHost) ...[
                ListTile(
                  leading: const Icon(Icons.output, color: Colors.orangeAccent),
                  title: const Text('Kick from Room', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Get.back();
                    // TODO: ফায়ারবেস বা কন্ট্রোলার দিয়ে কিক করার লজিক পরে অ্যাড করা হবে
                    Get.snackbar('Kicked', '${clickedUser.name} has been removed from the room.', backgroundColor: Colors.orangeAccent, colorText: Colors.white);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.redAccent),
                  title: const Text('Ban User permanently', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  onTap: () {
                    Get.back();
                    // TODO: ফায়ারবেসে ব্যান লিস্টে অ্যাড করার লজিক পরে অ্যাড করা হবে
                    Get.snackbar('Banned 🚫', '${clickedUser.name} is banned from this room.', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  },
                ),
              ]
              // 🚩 অডিয়েন্সের জন্য কন্ট্রোল (Report / Block)
              else ...[
                ListTile(
                  leading: const Icon(Icons.report_problem, color: Colors.orangeAccent),
                  title: const Text('Report User', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Get.back();
                    // TODO: ফায়ারবেসে রিপোর্ট সেভ করার লজিক পরে অ্যাড করা হবে
                    Get.snackbar('Reported', 'Thank you. We will review this user.', backgroundColor: Colors.orangeAccent, colorText: Colors.white);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block, color: Colors.redAccent),
                  title: const Text('Block User', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Get.back();
                    // TODO: ফায়ারবেসে ব্লক লিস্টে অ্যাড করা
                    Get.snackbar('Blocked 🚫', 'You will not see ${clickedUser.name} anymore.', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    String safeUserId = widget.userId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (safeUserId.isEmpty) {
      safeUserId = "user_${DateTime.now().millisecondsSinceEpoch}";
    }

    ZegoUIKitPrebuiltLiveAudioRoomConfig config = widget.isHost
        ? ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
        : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience();

    // 🎨 প্রিমিয়াম গ্রেডিয়েন্ট ব্যাকগ্রাউন্ড
    config.background = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 50, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.5), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.podcasts, color: Colors.cyanAccent, size: 20),
                  const SizedBox(width: 10),
                  Flexible(child: Text(widget.roomName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // 🪑 সিট লেআউট: 1 + 2 + 4 + 4 = 11 সিট
    config.seat.layout = ZegoLiveAudioRoomLayoutConfig(
      rowConfigs: [
        ZegoLiveAudioRoomLayoutRowConfig(count: 1, alignment: ZegoLiveAudioRoomLayoutAlignment.center),
        ZegoLiveAudioRoomLayoutRowConfig(count: 2, alignment: ZegoLiveAudioRoomLayoutAlignment.spaceEvenly),
        ZegoLiveAudioRoomLayoutRowConfig(count: 4, alignment: ZegoLiveAudioRoomLayoutAlignment.spaceAround),
        ZegoLiveAudioRoomLayoutRowConfig(count: 4, alignment: ZegoLiveAudioRoomLayoutAlignment.spaceAround),
      ],
    );

    if (widget.isHost) {
      config.seat.hostIndexes = [0];
    }

    // 🖼️ প্রোফাইল অবতার এবং ক্লিকেবল মেনু (UGC Implementation)
    config.seat.avatarBuilder = (BuildContext context, Size size, ZegoUIKitUser? user, Map<String, dynamic> extraInfo) {
      if (user == null || user.name.isEmpty) return const SizedBox();

      String firstLetter = user.name.trim().substring(0, 1).toUpperCase();

      return GestureDetector(
        onTap: () => _showUserActionMenu(context, user),
        child: CircleAvatar(
          radius: size.width / 2,
          backgroundColor: const Color(0xFF1A1A2E),
          backgroundImage: (user.id == safeUserId && widget.userAvatar.isNotEmpty)
              ? NetworkImage(widget.userAvatar)
              : null,
          child: (user.id != safeUserId || widget.userAvatar.isEmpty)
              ? Text(firstLetter, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 22))
              : null,
        ),
      );
    };

    return SafeArea(
      child: ZegoUIKitPrebuiltLiveAudioRoom(
        appID: 358538422,
        appSign: '7e4ad77a5ad88a14bdbfbda739b67e9de336d5c91aa0b00672c22eecd96823fa',
        userID: safeUserId,
        userName: widget.userName.isEmpty ? "Nova User" : widget.userName,
        roomID: widget.roomId,
        config: config,
      ),
    );
  }
}