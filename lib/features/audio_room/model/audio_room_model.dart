import 'package:flutter/material.dart';

class AudioRoom {
  final String id;
  final String roomName;
  final String topic;
  final int activeUsers;
  final IconData icon;
  final Color iconColor;

  AudioRoom({
    required this.id,
    required this.roomName,
    required this.topic,
    required this.activeUsers,
    required this.icon,
    required this.iconColor,
  });
}