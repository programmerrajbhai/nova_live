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
  // সার্ভার রেডি হওয়ার স্ট্যাটাস চেক করার ভেরিয়েবল
  bool isZimReady = false;

  @override
  void initState() {
    super.initState();
    _connectZIMFirst();
  }

  Future<void> _connectZIMFirst() async {
    try {
      // ১. প্লাগিন ইন্সটল
      ZegoUIKit().installPlugins([ZegoUIKitSignalingPlugin()]);

      // ২. 🔥 মাস্টার ফিক্স: 'await' বাদ দেওয়া হয়েছে কারণ এটি void ফাংশন
      ZegoUIKit().login(widget.userId, widget.userName);

      // ৩. সার্ভারকে কানেক্ট হওয়ার জন্য ব্যাকগ্রাউন্ডে ১ সেকেন্ড সময় দিচ্ছি
      await Future.delayed(const Duration(seconds: 1));

      // ৪. এরপর লোডিং স্ক্রিন সরিয়ে অডিও রুম দেখাবো
      if (mounted) {
        setState(() {
          isZimReady = true;
        });
      }
    } catch (e) {
      debugPrint("ZIM Login Failed: $e");
    }
  }

  @override
  void dispose() {
    if (widget.isHost) {
      FirebaseFirestore.instance.collection('live_audio_rooms').doc(widget.roomId).delete();
    }
    ZegoUIKit().logout();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // ⏳ যতক্ষণ লগিন না হচ্ছে, ততক্ষণ সুন্দর একটি লোডিং স্ক্রিন দেখাবে
    if (!isZimReady) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.purpleAccent),
              SizedBox(height: 15),
              Text("Connecting to Seat Server...", style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    ZegoUIKitPrebuiltLiveAudioRoomConfig config = widget.isHost
        ? ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
        : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience();

    config.background = Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?q=80&w=1000&auto=format&fit=crop'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(color: Colors.black.withOpacity(0.6)),
        ),
        Positioned(
          top: 50, left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purpleAccent, width: 1),
            ),
            child: Text(widget.roomName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );

    config.seat.layout = ZegoLiveAudioRoomLayoutConfig(
      rowConfigs: [
        ZegoLiveAudioRoomLayoutRowConfig(count: 4, alignment: ZegoLiveAudioRoomLayoutAlignment.spaceAround),
        ZegoLiveAudioRoomLayoutRowConfig(count: 4, alignment: ZegoLiveAudioRoomLayoutAlignment.spaceAround),
      ],
    );

    if (widget.isHost) {
      config.seat.hostIndexes = [0];
    }

    config.seat.avatarBuilder = (BuildContext context, Size size, ZegoUIKitUser? user, Map<String, dynamic> extraInfo) {
      if (user == null || user.name.isEmpty) return const SizedBox();

      String firstLetter = user.name.trim().isNotEmpty ? user.name.trim().substring(0, 1).toUpperCase() : 'U';

      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.purpleAccent, width: 2),
        ),
        child: CircleAvatar(
          radius: size.width / 2,
          backgroundColor: const Color(0xFF2A2A2A),
          backgroundImage: (user.id == widget.userId && widget.userAvatar.isNotEmpty)
              ? NetworkImage(widget.userAvatar)
              : null,
          child: (user.id != widget.userId || widget.userAvatar.isEmpty)
              ? Text(firstLetter, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))
              : null,
        ),
      );
    };

    return SafeArea(
      child: ZegoUIKitPrebuiltLiveAudioRoom(
        appID: 358538422,
        appSign: '7e4ad77a5ad88a14bdbfbda739b67e9de336d5c91aa0b00672c22eecd96823fa',
        userID: widget.userId,
        userName: widget.userName,
        roomID: widget.roomId,
        config: config,
      ),
    );
  }
}