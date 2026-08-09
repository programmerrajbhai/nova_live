import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../widgets/user_profile_sheet.dart';
import '../../../core/controllers/safety_controller.dart'; // 🔥 SafetyController ইম্পোর্ট

class ActiveAudioRoomView extends StatefulWidget {
  final String roomId;
  final String roomName;
  final String roomLogo;
  final bool isHost;
  final String userId;
  final String userName;
  final String userAvatar;

  // অ্যাডমিন কন্ট্রোলড প্রপার্টিজ
  final bool isOfficial;
  final String bgImage;
  final String bgMusic;

  const ActiveAudioRoomView({
    Key? key,
    required this.roomId,
    required this.roomName,
    required this.roomLogo,
    required this.isHost,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.isOfficial = false,
    this.bgImage = '',
    this.bgMusic = '',
  }) : super(key: key);

  @override
  State<ActiveAudioRoomView> createState() => _ActiveAudioRoomViewState();
}

class _ActiveAudioRoomViewState extends State<ActiveAudioRoomView> {
  final TextEditingController _reportController = TextEditingController();
  late StreamSubscription _banSubscription;
  late StreamSubscription _roomSubscription; // 🔥 অ্যাডমিন ফোর্স ক্লোজের জন্য
  late String safeUserId;

  @override
  void initState() {
    super.initState();
    ZegoUIKit().installPlugins([ZegoUIKitSignalingPlugin()]);

    safeUserId = widget.userId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (safeUserId.isEmpty) {
      safeUserId = "user_${DateTime.now().millisecondsSinceEpoch}";
    }

    // ব্যান চেকিং লজিক
    _banSubscription = FirebaseFirestore.instance
        .collection('banned_users')
        .doc(widget.roomId)
        .collection('users')
        .doc(safeUserId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        ZegoUIKit().leaveRoom();
        Get.back();
        Get.snackbar(
          'Banned 🚫',
          'You are permanently banned from this room.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    });

    // 🔥 Admin Force Close Listener
    _roomSubscription = FirebaseFirestore.instance
        .collection('live_audio_rooms')
        .doc(widget.roomId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists && !widget.isHost) {
        ZegoUIKit().leaveRoom();
        Get.back();
        Get.snackbar(
          'Room Closed 🛑',
          'This room was closed by moderation or host.',
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    });
  }

  @override
  void dispose() {
    _banSubscription.cancel();
    _roomSubscription.cancel(); // 🔥 লিসেনার ক্যানসেল
    _reportController.dispose();

    if (widget.isHost && !widget.isOfficial) {
      FirebaseFirestore.instance.collection('live_audio_rooms').doc(widget.roomId).delete();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ZegoUIKitPrebuiltLiveAudioRoomConfig config = widget.isHost
        ? ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
        : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience();

    // ==========================================
    // কাস্টম ব্যাকগ্রাউন্ড (Official vs Regular)
    // ==========================================
    config.background = widget.isOfficial && widget.bgImage.isNotEmpty
        ? Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(widget.bgImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.65), BlendMode.darken),
        ),
      ),
    )
        : Stack(
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
          top: -50, left: -50,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.pinkAccent.withOpacity(0.15)),
            child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50), child: Container(color: Colors.transparent)),
          ),
        ),
        Positioned(
          bottom: 100, right: -50,
          child: Container(
            width: 250, height: 250,
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
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: widget.isOfficial ? Colors.amber.withOpacity(0.5) : Colors.white.withOpacity(0.2), width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[800],
                              backgroundImage: widget.roomLogo.isNotEmpty ? NetworkImage(widget.roomLogo) : null,
                              child: widget.roomLogo.isEmpty ? const Icon(Icons.meeting_room, color: Colors.white) : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      if (widget.isOfficial)
                                        const Icon(Icons.verified, color: Colors.amber, size: 14),
                                      if (widget.isOfficial)
                                        const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          widget.roomName.isEmpty ? "Live Room" : widget.roomName,
                                          style: TextStyle(color: widget.isOfficial ? Colors.amber : Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "ID: ${widget.roomId.replaceAll('room_', '')}",
                                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: widget.isOfficial ? [Colors.amber, Colors.orange] : [Colors.pinkAccent, Colors.deepPurpleAccent]),
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
                    const SizedBox(width: 45), // Zego-এর ক্লোজ বাটনের জন্য স্পেস
                  ],
                ),
              ],
            ),

            // ==========================================
            // অফিসিয়াল ব্যাকগ্রাউন্ড মিউজিক ইউআই ইন্ডিকেটর
            // ==========================================
            if (widget.isOfficial && widget.bgMusic.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.music_note_rounded, color: Colors.amber, size: 16),
                      SizedBox(width: 6),
                      Text("Official Event BGM Playing", style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
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
        behavior: HitTestBehavior.opaque,
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
            border: Border.all(color: isMe ? Colors.cyanAccent : (widget.isOfficial ? Colors.amber : Colors.pinkAccent).withOpacity(0.6), width: 2.5),
            boxShadow: [
              BoxShadow(color: (isMe ? Colors.cyanAccent : (widget.isOfficial ? Colors.amber : Colors.pinkAccent)).withOpacity(0.4), blurRadius: 10, spreadRadius: 1)
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

  // 🔥 SafetyController ব্যবহার করে সেন্ট্রাল রিপোর্ট সিস্টেম
  void _showReportDialog(BuildContext context, String currentUserId) {
    final SafetyController safetyController = Get.put(SafetyController());
    final List<String> reportReasons = [
      'Nudity or sexually explicit content',
      'Hate speech or symbols',
      'Violence or dangerous behavior',
      'Bullying or harassment',
      'Scam or fraud',
      'Spam'
    ];
    String selectedReason = reportReasons[0];

    _reportController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setState) {
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
                    DropdownButtonFormField<String>(
                      value: selectedReason,
                      dropdownColor: const Color(0xFF2C2C2C),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      items: reportReasons.map((reason) => DropdownMenuItem(value: reason, child: Text(reason))).toList(),
                      onChanged: (value) => setState(() => selectedReason = value!),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _reportController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Additional details...",
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
                  Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: safetyController.isProcessing.value ? null : () {
                      // 🔥 Safety Controller কল
                      safetyController.submitReport(
                        reportedUserId: widget.roomId.replaceAll('room_', ''), // Host ID
                        roomId: widget.roomId,
                        reason: selectedReason,
                        details: _reportController.text.trim(),
                        source: 'audio_room',
                      );
                    },
                    child: safetyController.isProcessing.value
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Submit", style: TextStyle(color: Colors.white)),
                  )),
                ],
              );
            }
        );
      },
    );
  }
}