import 'package:cloud_firestore/cloud_firestore.dart';

class AudioRoomModel {
  final String roomId;
  final String hostId;
  final String hostName;
  final String hostAvatar;
  final String roomName;
  final Timestamp? createdAt;

  AudioRoomModel({
    required this.roomId,
    required this.hostId,
    required this.hostName,
    required this.hostAvatar,
    required this.roomName,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'hostId': hostId,
      'hostName': hostName,
      'hostAvatar': hostAvatar,
      'roomName': roomName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory AudioRoomModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AudioRoomModel(
      roomId: data['roomId'] ?? '',
      hostId: data['hostId'] ?? '',
      hostName: data['hostName'] ?? 'User',
      hostAvatar: data['hostAvatar'] ?? '',
      roomName: data['roomName'] ?? 'Nova Live Room',
      createdAt: data['createdAt'],
    );
  }
}