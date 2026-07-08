import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../widgets/user_profile_sheet.dart';

class ActiveAudioRoomView extends StatefulWidget {
  final String roomId;
  final String roomName;
  final String roomLogo; // 🔥 নতুন: রুম লোগো
  final bool isHost;
  final String userId;
  final String userName;
  final String userAvatar;

  const ActiveAudioRoomView({
    Key? key,
    required this.roomId,
    required this.roomName,
    required this.roomLogo, // 🔥 কনস্ট্রাক্টরে রিসিভ করা হলো
    required this.isHost,
    required this.userId,
    required this.userName,
    required this.userAvatar,
  }) : super(key: key);

  @override
  State<ActiveAudioRoomView> createState() => _ActiveAudioRoomViewState();
}

class _ActiveAudioRoomViewState extends State<ActiveAudioRoomView> {
  final TextEditingController _reportController = TextEditingController();
  late StreamSubscription _banSubscription;
  late String safeUserId;

  @override
  void initState() {
    super.initState();
    ZegoUIKit().installPlugins([ZegoUIKitSignalingPlugin()]);

    safeUserId = widget.userId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (safeUserId.isEmpty) {
      safeUserId = "user_${DateTime.now().millisecondsSinceEpoch}";
    }

    // 🔥 ১০০০% পারফেক্ট ব্যান প্রটেকশন:
    // যদি ইউজার ব্যানড থাকে, তবে পেজ লোড হতেই তাকে বের করে দেওয়া হবে
    _banSubscription = FirebaseFirestore.instance
        .collection('banned_users')
        .doc(widget.roomId)
        .collection('users')
        .doc(safeUserId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        ZegoUIKit().leaveRoom(); // Zego থেকে লিভ
        Get.back(); // পেজ থেকে বের করে দেওয়া
        Get.snackbar(
          'Banned 🚫',
          'You are permanently banned from this room.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    });
  }

  @override
  void dispose() {
    _banSubscription.cancel(); // লিসেনার ক্লোজ করা হলো
    _reportController.dispose();
    if (widget.isHost) {
      FirebaseFirestore.instance.collection('live_audio_rooms').doc(widget.roomId).delete();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ZegoUIKitPrebuiltLiveAudioRoomConfig config = widget.isHost
        ? ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
        : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience();

    config.background = Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F0518), Color(0xFF1A0B2E), Color(0xFF0F0518)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.pinkAccent.withOpacity(0.15)),
            child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container(color: Colors.transparent)),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.cyanAccent.withOpacity(0.1)),
            child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container(color: Colors.transparent)),
          ),
        ),
      ],
    );

    config.foreground = SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 🔥 রুম লোগো দেখানো হচ্ছে
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[800],
                              backgroundImage: widget.roomLogo.isNotEmpty
                                  ? NetworkImage(widget.roomLogo)
                                  : null,
                              child: widget.roomLogo.isEmpty
                                  ? const Icon(Icons.meeting_room, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.roomName.isEmpty ? "Live Room" : widget.roomName,
                                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "ID: ${widget.roomId.replaceAll('room_', '')}",
                                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Colors.pinkAccent, Colors.deepPurpleAccent]),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text("Follow", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                        color: const Color(0xFF2C1B3D),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        onSelected: (value) {
                          if (value == 'report') {
                            _showReportDialog(context, safeUserId);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            value: 'report',
                            child: Row(
                              children: [
                                Icon(Icons.report_problem, color: Colors.redAccent, size: 18),
                                SizedBox(width: 10),
                                Text('Report Room', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 45),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    config.seat.layout = ZegoLiveAudioRoomLayoutConfig(
      rowConfigs: [
        ZegoLiveAudioRoomLayoutRowConfig(count: 4, alignment: ZegoLiveAudioRoomLayoutAlignment.spaceAround),
        ZegoLiveAudioRoomLayoutRowConfig(count: 4, alignment: ZegoLiveAudioRoomLayoutAlignment.spaceAround),
        ZegoLiveAudioRoomLayoutRowConfig(count: 4, alignment: ZegoLiveAudioRoomLayoutAlignment.spaceAround),
      ],
    );

    if (widget.isHost) {
      config.seat.hostIndexes = [0];
    }

    config.seat.avatarBuilder = (BuildContext context, Size size, ZegoUIKitUser? user, Map<String, dynamic> extraInfo) {
      if (user == null || user.name.isEmpty) return const SizedBox();

      String firstLetter = user.name.trim().substring(0, 1).toUpperCase();
      bool isMe = user.id == safeUserId;

      return GestureDetector(
        behavior: HitTestBehavior.opaque, // 🔥 অডিয়েন্সদের প্রোফাইল ক্লিকেবল না হওয়ার সমস্যাটি এটি ফিক্স করবে।
        onTap: () {
          UserProfileSheet.show(
            context: context,
            clickedUser: user,
            isHost: widget.isHost,
            roomId: widget.roomId,
            currentUserId: safeUserId,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isMe ? Colors.cyanAccent : Colors.pinkAccent.withOpacity(0.6), width: 2.5),
            boxShadow: [
              BoxShadow(color: (isMe ? Colors.cyanAccent : Colors.pinkAccent).withOpacity(0.4), blurRadius: 10, spreadRadius: 1)
            ],
          ),
          child: CircleAvatar(
            radius: size.width / 2,
            backgroundColor: const Color(0xFF1A1A2E),
            backgroundImage: (isMe && widget.userAvatar.isNotEmpty) ? NetworkImage(widget.userAvatar) : null,
            child: (!isMe || widget.userAvatar.isEmpty)
                ? Text(firstLetter, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20))
                : null,
          ),
        ),
      );
    };

    return Scaffold(
      body: ZegoUIKitPrebuiltLiveAudioRoom(
        appID: 358538422,
        appSign: '7e4ad77a5ad88a14bdbfbda739b67e9de336d5c91aa0b00672c22eecd96823fa',
        userID: safeUserId,
        userName: widget.userName.isEmpty ? "Nova User" : widget.userName,
        roomID: widget.roomId,
        config: config,
      ),
    );
  }

  void _showReportDialog(BuildContext context, String currentUserId) {
    _reportController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C1B3D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.report_gmailerrorred, color: Colors.redAccent),
              SizedBox(width: 10),
              Text("Report Room", style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Why are you reporting this room?", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              TextField(
                controller: _reportController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Type reason here...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                if (_reportController.text.trim().isEmpty) {
                  Get.snackbar('Error', 'Please provide a reason.', backgroundColor: Colors.redAccent, colorText: Colors.white);
                  return;
                }
                Navigator.pop(context);

                await FirebaseFirestore.instance.collection('reports_rooms').add({
                  'room_id': widget.roomId,
                  'reported_by': currentUserId,
                  'reason': _reportController.text.trim(),
                  'timestamp': FieldValue.serverTimestamp(),
                });

                Get.snackbar('Reported', 'Action will be taken after review. Thank you.', backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
              },
              child: const Text("Submit", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}