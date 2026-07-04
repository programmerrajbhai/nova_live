import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../model/audio_room_model.dart';
import '../view/active_audio_room_view.dart';

class AudioRoomController extends GetxController {
  var roomList = <AudioRoom>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRooms();
  }

  void fetchRooms() {
    roomList.value = [
      AudioRoom(id: '1', roomName: 'Midnight Chill 🌙', topic: 'Music & Adda', activeUsers: 45, icon: FontAwesomeIcons.music, iconColor: Colors.orangeAccent),
      AudioRoom(id: '2', roomName: 'Singles Cafe ☕', topic: 'Friendship', activeUsers: 120, icon: FontAwesomeIcons.mugHot, iconColor: Colors.pinkAccent),
      AudioRoom(id: '3', roomName: 'Tech Talk BD 💻', topic: 'Technology', activeUsers: 15, icon: FontAwesomeIcons.laptopCode, iconColor: Colors.cyanAccent),
    ];
  }

  void joinRoom(AudioRoom room) {
    // সরাসরি নতুন পেজে নেভিগেশন (Zoom ট্রানজিশন সহ)
    Get.to(() => ActiveAudioRoomView(room: room), transition: Transition.zoom);
  }
}