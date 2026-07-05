import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActiveAudioRoomView extends StatefulWidget {
  final String roomId;
  final String roomName;
  final bool isHost;
  final String userId;
  final String userName;
  final String userAvatar;

  const ActiveAudioRoomView({
    Key? key,
    required this.roomId,
    required this.roomName,
    required this.isHost,
    required this.userId,
    required this.userName,
    required this.userAvatar,
  }) : super(key: key);

  @override
  State<ActiveAudioRoomView> createState() => _ActiveAudioRoomViewState();
}

class _ActiveAudioRoomViewState extends State<ActiveAudioRoomView> {

  @override
  void dispose() {
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
            image: DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?q=80&w=1000&auto=format&fit=crop'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(color: Colors.black.withOpacity(0.6)),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purpleAccent, width: 1),
              boxShadow: [BoxShadow(color: Colors.purpleAccent.withOpacity(0.3), blurRadius: 10)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.graphic_eq, color: Colors.purpleAccent, size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.roomName,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.isHost) {
      config.seat.hostIndexes = [0];
    }

    config.seat.layout = ZegoLiveAudioRoomLayoutConfig(
      rowConfigs: [
        ZegoLiveAudioRoomLayoutRowConfig(count: 4, alignment: ZegoLiveAudioRoomLayoutAlignment.spaceAround),
        ZegoLiveAudioRoomLayoutRowConfig(count: 4, alignment: ZegoLiveAudioRoomLayoutAlignment.spaceAround),
      ],
    );

    config.seat.avatarBuilder = (BuildContext context, Size size, ZegoUIKitUser? user, Map<String, dynamic> extraInfo) {
      if (user == null || user.name.isEmpty) {
        return const SizedBox();
      }

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
              ? Text(
              firstLetter,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
          )
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