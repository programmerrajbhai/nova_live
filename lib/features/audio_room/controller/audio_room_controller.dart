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

  Future<void> startMyRoom(String customRoomName) async {
    if (safeUserId.isEmpty) return;

    isCreatingRoom.value = true;

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
      );

      await _db.collection('live_audio_rooms').doc(roomId).set(newRoom.toMap());

      pickedLogo = null;
      pickedLogoPath.value = '';
      isCreatingRoom.value = false;

      Get.to(() => ActiveAudioRoomView(
        roomId: roomId,
        roomName: roomName,
        roomLogo: logoUrl,
        isHost: true,
        userId: safeUserId,
        userName: myName.value.isEmpty ? "Nova Host" : myName.value,
        userAvatar: myAvatar.value,
      ));
    } catch (e) {
      isCreatingRoom.value = false;

      Get.snackbar(
        'Error ⚠️',
        'Failed to start room: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  void joinRoom(String roomId, String roomName, String roomLogo) {
    if (safeUserId.isEmpty) return;

    Get.to(() => ActiveAudioRoomView(
      roomId: roomId,
      roomName: roomName,
      roomLogo: roomLogo,
      isHost: false,
      userId: safeUserId,
      userName: myName.value.isEmpty ? "Nova Speaker" : myName.value,
      userAvatar: myAvatar.value,
    ));
  }
}