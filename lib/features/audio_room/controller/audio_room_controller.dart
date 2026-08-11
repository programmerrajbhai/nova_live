import 'dart:async';
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

  // 🔥 লোকাল ব্লক লিস্ট (N+1 Problem এবং Database Overload ঠেকানোর জন্য)
  final RxSet<String> blockedUsers = <String>{}.obs;
  StreamSubscription? _blockedUsersSub;
  StreamSubscription? _blockedBySub;

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
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        myName.value = data['name'] ?? 'Nova User';
        myAvatar.value = data['avatar'] ?? '';
      }
      _listenToBlocks(); // 🔥 ব্লক লিস্ট RAM-এ লোড করা হচ্ছে
    }
  }

  // 🔥 রিয়েলটাইম ব্লক লিস্ট লিসেনার
  void _listenToBlocks() {
    if (myUid.value.isEmpty) return;

    _blockedUsersSub = _db.collection('users').doc(myUid.value).collection('blocked_users').snapshots().listen((snap) {
      for(var doc in snap.docs) blockedUsers.add(doc.id);
    });

    _blockedBySub = _db.collection('users').doc(myUid.value).collection('blocked_by').snapshots().listen((snap) {
      for(var doc in snap.docs) blockedUsers.add(doc.id);
    });
  }

  // 🔥 BUG FIXED: N+1 Problem সলভড! (asyncMap এবং await বাদ দিয়ে O(1) ক্যাশ ব্যবহার করা হলো)
  Stream<List<AudioRoomModel>> getLiveRoomsStream() {
    return _db
        .collection('live_audio_rooms')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {

      List<AudioRoomModel> validRooms = [];
      for (var doc in snapshot.docs) {
        final room = AudioRoomModel.fromDocument(doc);

        // লোকাল RAM থেকে চেক করছে, কোনো ফায়ারবেস রিড হচ্ছে না
        if (!blockedUsers.contains(room.hostId)) {
          validRooms.add(room);
        }
      }
      return validRooms;
    });
  }

  String get safeUserId {
    final id = myUid.value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return id.isNotEmpty ? id : "user_${DateTime.now().millisecondsSinceEpoch}";
  }

  Future<void> pickRoomLogo() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 700);
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
          return;
        }
      }
    } catch (e) {
      debugPrint("Failed to check room permissions: $e");
    }

    final roomId = 'room_$safeUserId';
    final roomName = customRoomName.trim().isEmpty ? "${myName.value}'s Live Adda" : customRoomName.trim();

    try {
      final logoUrl = await _uploadLogo(roomId);
      final newRoom = AudioRoomModel(
        roomId: roomId, hostId: safeUserId, hostName: myName.value.isEmpty ? 'Nova Host' : myName.value,
        hostAvatar: myAvatar.value, roomName: roomName, roomLogo: logoUrl, isOfficial: false,
      );

      await _db.collection('live_audio_rooms').doc(roomId).set(newRoom.toMap());
      pickedLogo = null; pickedLogoPath.value = ''; isCreatingRoom.value = false;

      // 🔥 Get.to() ব্যবহার করা হয়েছে, যাতে ব্যাক করলে অ্যাপ রিস্টার্ট না নেয় (Fixes #29)
      Get.to(() => ActiveAudioRoomView(
        roomId: roomId, roomName: roomName, roomLogo: logoUrl, isHost: true,
        userId: safeUserId, userName: myName.value.isEmpty ? "Nova Host" : myName.value,
        userAvatar: myAvatar.value, hostId: safeUserId, isOfficial: false, bgImage: '', bgMusic: '',
      ));
    } catch (e) {
      isCreatingRoom.value = false;
      Get.snackbar('Error', 'Failed to start room: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // ===============================================
  // ২. অন্য রুমে জয়েন করার লজিক
  // ===============================================
  Future<void> joinRoom(AudioRoomModel room) async {
    if (safeUserId.isEmpty) return;

    // 🔥 O(1) RAM Cache Check (No N+1 Issue)
    if (blockedUsers.contains(room.hostId)) {
      Get.snackbar('Access Denied', 'You cannot join this room.', backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // 🔥 Get.to() ব্যবহার করা হয়েছে (Fixes #29)
    Get.to(() => ActiveAudioRoomView(
      roomId: room.roomId, roomName: room.roomName, roomLogo: room.roomLogo, isHost: false,
      userId: safeUserId, userName: myName.value.isEmpty ? "Nova Speaker" : myName.value,
      userAvatar: myAvatar.value, hostId: room.hostId, isOfficial: room.isOfficial, bgImage: room.bgImage, bgMusic: room.bgMusic,
    ));
  }

  // 🔥 মেমোরি লিক রোধ করার জন্য লিসেনার ক্যানসেল করা হলো
  @override
  void onClose() {
    _blockedUsersSub?.cancel();
    _blockedBySub?.cancel();
    super.onClose();
  }
}