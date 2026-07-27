import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/audio_room_model.dart';
import '../view/active_audio_room_view.dart';

class AudioRoomController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var myUid = ''.obs;
  var myName = ''.obs;
  var myAvatar = ''.obs;

  var isCreatingRoom = false.obs;
  var pickedLogoPath = ''.obs;
  XFile? pickedLogo;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    myUid.value = prefs.getString('uid') ?? '';
    if (myUid.value.isNotEmpty) {
      final doc = await _db.collection('users').doc(myUid.value).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        myName.value = data['name'] ?? 'Nova User';
        myAvatar.value = data['avatar'] ?? '';
      }
    }
  }

  Stream<List<AudioRoomModel>> getLiveRoomsStream() {
    return _db
        .collection('live_audio_rooms')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AudioRoomModel.fromDocument(doc)).toList();
    });
  }

  String get safeUserId {
    final id = myUid.value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return id.isNotEmpty ? id : "user_${DateTime.now().millisecondsSinceEpoch}";
  }

  Future<void> pickRoomLogo() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 700,
    );
    if (image != null) {
      pickedLogo = image;
      pickedLogoPath.value = image.path;
    }
  }

  Future<String> _uploadLogo(String roomId) async {
    if (pickedLogo == null) return myAvatar.value;
    final ref = FirebaseStorage.instance.ref().child('room_logos/$roomId.jpg');
    await ref.putFile(File(pickedLogo!.path));
    return await ref.getDownloadURL();
  }

  // ===============================================
  // ১. অ্যাডমিন পারমিশন চেক করে রুম খোলার লজিক
  // ===============================================
  Future<void> startMyRoom(String customRoomName) async {
    if (safeUserId.isEmpty) return;

    isCreatingRoom.value = true;

    // আগে ফায়ারবেস থেকে চেক করুন ইউজারদের রুম খোলার পারমিশন আছে কি না
    try {
      DocumentSnapshot configDoc = await _db.collection('settings').doc('room_controls').get();
      if (configDoc.exists && configDoc.data() != null) {
        bool allowRooms = (configDoc.data() as Map<String, dynamic>)['allowUserRooms'] ?? true;
        if (!allowRooms) {
          isCreatingRoom.value = false;
          Get.snackbar(
            'Access Denied 🛑',
            'Room creation is temporarily disabled by the Administrator.',
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          return; // এখানেই আটকে যাবে
        }
      }
    } catch (e) {
      debugPrint("Failed to check room permissions: $e");
    }

    final roomId = 'room_$safeUserId';
    final roomName = customRoomName.trim().isEmpty
        ? "${myName.value}'s Live Adda"
        : customRoomName.trim();

    try {
      final logoUrl = await _uploadLogo(roomId);
      final newRoom = AudioRoomModel(
        roomId: roomId,
        hostId: safeUserId,
        hostName: myName.value.isEmpty ? 'Nova Host' : myName.value,
        hostAvatar: myAvatar.value,
        roomName: roomName,
        roomLogo: logoUrl,
        isOfficial: false, // সাধারণ ইউজারের রুম অফিশিয়াল নয়
      );

      await _db.collection('live_audio_rooms').doc(roomId).set(newRoom.toMap());

      pickedLogo = null;
      pickedLogoPath.value = '';
      isCreatingRoom.value = false;

      // রুমে জয়েন করানো হচ্ছে
      Get.to(() => ActiveAudioRoomView(
        roomId: roomId,
        roomName: roomName,
        roomLogo: logoUrl,
        isHost: true,
        userId: safeUserId,
        userName: myName.value.isEmpty ? "Nova Host" : myName.value,
        userAvatar: myAvatar.value,
        isOfficial: false,
        bgImage: '',
        bgMusic: '',
      ));
    } catch (e) {
      isCreatingRoom.value = false;
      Get.snackbar('Error', 'Failed to start room: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // ===============================================
  // ২. অন্য রুমে জয়েন করার লজিক (Official Room Data পাস করা)
  // ===============================================
  void joinRoom(AudioRoomModel room) {
    if (safeUserId.isEmpty) return;
    Get.to(() => ActiveAudioRoomView(
      roomId: room.roomId,
      roomName: room.roomName,
      roomLogo: room.roomLogo,
      isHost: false, // ইউজার জয়েন করলে সে হোস্ট নয়
      userId: safeUserId,
      userName: myName.value.isEmpty ? "Nova Speaker" : myName.value,
      userAvatar: myAvatar.value,
      isOfficial: room.isOfficial,
      bgImage: room.bgImage,
      bgMusic: room.bgMusic,
    ));
  }
}