import 'package:flutter/material.dart';
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
    // সিট ম্যানেজমেন্টের প্লাগিন চালু করা হলো
    ZegoUIKit().installPlugins([ZegoUIKitSignalingPlugin()]);
  }

  @override
  void dispose() {
    if (widget.isHost) {
      FirebaseFirestore.instance.collection('live_audio_rooms').doc(widget.roomId).delete();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // সার্ভার লগিন এরর বন্ধ করার জন্য সেফ ইউজার আইডি
    String safeUserId = widget.userId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (safeUserId.isEmpty) {
      safeUserId = "user_${DateTime.now().millisecondsSinceEpoch}";
    }

    // 🔥 MASTER FIX: .speaker() বাদ দিয়ে .audience() দেওয়া হলো।
    // অডিয়েন্সরা যেকোনো খালি সিটে ক্লিক করলেই বসতে পারবে!
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

    // 🪑 সিট লেআউট: 1 (Host) + 2 + 4 + 4 = 11 সিট
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

    // 🖼️ ক্লিন প্রোফাইল (যাতে কথা বলার সময় ভয়েস ওয়েভ বা ঢেউ একদম পারফেক্টলি দেখা যায়)
    config.seat.avatarBuilder = (BuildContext context, Size size, ZegoUIKitUser? user, Map<String, dynamic> extraInfo) {
      if (user == null || user.name.isEmpty) return const SizedBox();

      String firstLetter = user.name.trim().substring(0, 1).toUpperCase();

      return CircleAvatar(
        radius: size.width / 2,
        backgroundColor: const Color(0xFF1A1A2E),
        backgroundImage: (user.id == safeUserId && widget.userAvatar.isNotEmpty)
            ? NetworkImage(widget.userAvatar)
            : null,
        child: (user.id != safeUserId || widget.userAvatar.isEmpty)
            ? Text(firstLetter, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 22))
            : null,
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