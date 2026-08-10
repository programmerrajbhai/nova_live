import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/content_filter_service.dart';

class MessagesController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var myUid = ''.obs;
  var myName = ''.obs;
  var myAvatar = ''.obs;
  final messageController = TextEditingController();

  var isSearching = false.obs;
  var searchQuery = ''.obs;
  final searchController = TextEditingController();

  final RxSet<String> blockedUsers = <String>{}.obs;
  final Set<String> _iBlockedUsers = <String>{};
  final Set<String> _usersWhoBlockedMe = <String>{};

  StreamSubscription<QuerySnapshot>? _blockedUsersSubscription;
  StreamSubscription<QuerySnapshot>? _blockedBySubscription;

  @override
  void onInit() {
    super.onInit();
    _loadMyData();
  }

  Future<void> _loadMyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      myUid.value = prefs.getString('uid') ?? '';
      if (myUid.value.isEmpty) return;

      final doc = await _db.collection('users').doc(myUid.value).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        myName.value = (data['name'] ?? 'User').toString();
        myAvatar.value = (data['avatar'] ?? '').toString();
      }
      _listenToBlockedUsers();
    } catch (e) {
      debugPrint('MessagesController _loadMyData error: $e');
    }
  }

  void _listenToBlockedUsers() {
    if (myUid.value.isEmpty) return;

    _blockedUsersSubscription?.cancel();
    _blockedBySubscription?.cancel();

    _blockedUsersSubscription = _db.collection('users').doc(myUid.value).collection('blocked_users').snapshots().listen((snapshot) {
      _iBlockedUsers..clear()..addAll(snapshot.docs.map((doc) => doc.id));
      _refreshCombinedBlockedUsers();
    });

    _blockedBySubscription = _db.collection('users').doc(myUid.value).collection('blocked_by').snapshots().listen((snapshot) {
      _usersWhoBlockedMe..clear()..addAll(snapshot.docs.map((doc) => doc.id));
      _refreshCombinedBlockedUsers();
    });
  }

  void _refreshCombinedBlockedUsers() {
    final combined = <String>{..._iBlockedUsers, ..._usersWhoBlockedMe};
    blockedUsers.assignAll(combined);
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      searchQuery.value = '';
    }
  }

  // 🔥 BUG FIXED: N+1 Problem সলভড! asyncMap এবং await BlockService সরিয়ে ফেলা হয়েছে।
  Stream<List<QueryDocumentSnapshot>> getInboxStream() {
    return _db
        .collection('chat_rooms')
        .where('participants', arrayContains: myUid.value)
        .snapshots()
        .map((snapshot) { // asyncMap এর বদলে নরমাল map ব্যবহার করা হলো

      final List<QueryDocumentSnapshot> validDocs = [];

      for (final doc in snapshot.docs) {
        final roomData = doc.data() as Map<String, dynamic>? ?? {};
        final List<dynamic> participants = roomData['participants'] ?? [];
        final targetUid = participants.map((e) => e.toString()).firstWhere((id) => id != myUid.value, orElse: () => '');

        if (targetUid.isEmpty) continue;

        // লোকাল RAM থেকে চেক করছে, কোনো ফায়ারবেস ডেটাবেস কল হচ্ছে না!
        if (!blockedUsers.contains(targetUid)) {
          validDocs.add(doc);
        }
      }
      return validDocs;
    });
  }

  Stream<QuerySnapshot> getChatMessages(String roomId) {
    return _db.collection('chat_rooms').doc(roomId).collection('messages').orderBy('timestamp', descending: true).snapshots();
  }

  String getTimeAgo(dynamic timeData) {
    if (timeData == null) return 'Just now';
    DateTime date = timeData is Timestamp ? timeData.toDate() : (timeData is int ? DateTime.fromMillisecondsSinceEpoch(timeData) : DateTime.now());

    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  String formatMessageTime(dynamic timeData) {
    if (timeData == null) return 'Sending...';
    DateTime date = timeData is Timestamp ? timeData.toDate() : (timeData is int ? DateTime.fromMillisecondsSinceEpoch(timeData) : DateTime.now());

    int hour = date.hour;
    final minute = date.minute;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final minStr = minute < 10 ? '0$minute' : '$minute';
    return '$hour:$minStr $ampm';
  }

  Future<void> sendMessage(String roomId, String targetUid, String targetName, String targetAvatar) async {
    final text = messageController.text.trim();
    if (text.isEmpty || myUid.value.isEmpty || targetUid.isEmpty) return;

    final moderationResult = ContentFilterService.validate(text);
    if (!moderationResult.isAllowed) {
      Get.snackbar('Message Blocked', moderationResult.reason, backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 4));
      return;
    }

    if (blockedUsers.contains(targetUid)) {
      Get.snackbar('Action Denied', 'You cannot send messages to this user right now.', backgroundColor: Colors.grey[800], colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final exactTime = DateTime.now().millisecondsSinceEpoch;
    try {
      final batch = _db.batch();
      final messageRef = _db.collection('chat_rooms').doc(roomId).collection('messages').doc();

      batch.set(messageRef, {'senderId': myUid.value, 'text': text, 'timestamp': exactTime, 'type': 'text'});

      final roomRef = _db.collection('chat_rooms').doc(roomId);
      batch.set(roomRef, {
        'participants': FieldValue.arrayUnion([myUid.value, targetUid]),
        'lastMessage': text,
        'lastUpdated': exactTime,
        'usersData': {
          myUid.value: {'name': myName.value.isNotEmpty ? myName.value : 'User', 'avatar': myAvatar.value},
          targetUid: {'name': targetName.isNotEmpty ? targetName : 'User', 'avatar': targetAvatar},
        },
      }, SetOptions(merge: true));

      await batch.commit();
      messageController.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send message.', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // 🔥 BUG FIXED: Memory Leak ঠেকানোর জন্য লিসেনার ক্যানসেল করা হলো
  @override
  void onClose() {
    _blockedUsersSubscription?.cancel();
    _blockedBySubscription?.cancel();
    messageController.dispose();
    searchController.dispose();
    super.onClose();
  }
}