import 'package:cloud_firestore/cloud_firestore.dart';

class AudioRoomModel {
  final String roomId;
  final String hostId;
  final String hostName;
  final String hostAvatar;
  final String roomName;
  final String roomLogo;

  // অ্যাডমিন কন্ট্রোলড স্পেশাল ফিচার
  final bool isOfficial;
  final String bgImage;
  final String bgMusic;

  AudioRoomModel({
    required this.roomId,
    required this.hostId,
    required this.hostName,
    required this.hostAvatar,
    required this.roomName,
    required this.roomLogo,
    this.isOfficial = false,
    this.bgImage = '',
    this.bgMusic = '',
  });

  factory AudioRoomModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AudioRoomModel(
      roomId: doc.id,
      hostId: data['hostId'] ?? '',
      hostName: data['hostName'] ?? 'Nova User',
      hostAvatar: data['hostAvatar'] ?? '',
      roomName: data['roomName'] ?? 'Nova Live Room',
      roomLogo: data['roomLogo'] ?? data['hostAvatar'] ?? '',
      isOfficial: data['isOfficial'] ?? false,
      bgImage: data['bgImage'] ?? '',
      bgMusic: data['bgMusic'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'hostId': hostId,
      'hostName': hostName,
      'hostAvatar': hostAvatar,
      'roomName': roomName,
      'roomLogo': roomLogo,
      'isOfficial': isOfficial,
      'bgImage': bgImage,
      'bgMusic': bgMusic,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}