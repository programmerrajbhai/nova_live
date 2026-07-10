import 'package:cloud_firestore/cloud_firestore.dart';

class AudioRoomModel {
  final String roomId;
  final String hostId;
  final String hostName;
  final String hostAvatar;
  final String roomName;
  final String roomLogo;

  AudioRoomModel({
    required this.roomId,
    required this.hostId,
    required this.hostName,
    required this.hostAvatar,
    required this.roomName,
    required this.roomLogo,
  });

  factory AudioRoomModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AudioRoomModel(
      roomId: data['roomId'] ?? '',
      hostId: data['hostId'] ?? '',
      hostName: data['hostName'] ?? 'Nova User',
      hostAvatar: data['hostAvatar'] ?? '',
      roomName: data['roomName'] ?? 'Nova Live Room',
      roomLogo: data['roomLogo'] ?? data['hostAvatar'] ?? '',
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
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}