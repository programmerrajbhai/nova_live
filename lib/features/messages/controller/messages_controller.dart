import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/content_filter_service.dart';
import '../../../core/services/block_service.dart';

class MessagesController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var myUid = ''.obs;
  var myName = ''.obs;
  var myAvatar = ''.obs;

  final messageController = TextEditingController();

  var isSearching = false.obs;
  var searchQuery = ''.obs;
  final searchController = TextEditingController();

  // ============================================================
  // 🔥 Reactive Mutual Block List
  // blocked_users + blocked_by দুইটাই এখানে থাকবে
  // ============================================================
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

  // ============================================================
  // Load Current User
  // ============================================================
  Future<void> _loadMyData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      myUid.value = prefs.getString('uid') ?? '';

      if (myUid.value.isEmpty) {
        return;
      }

      final doc = await _db
          .collection('users')
          .doc(myUid.value)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>? ?? {};

        myName.value = (data['name'] ?? 'User').toString();
        myAvatar.value = (data['avatar'] ?? '').toString();
      }

      // 🔥 User data load হওয়ার পর block listeners start
      _listenToBlockedUsers();
    } catch (e) {
      debugPrint('MessagesController _loadMyData error: $e');
    }
  }

  // ============================================================
  // 🔥 Listen to blocked_users + blocked_by
  // ============================================================
  void _listenToBlockedUsers() {
    if (myUid.value.isEmpty) return;

    // আগের listener থাকলে cancel
    _blockedUsersSubscription?.cancel();
    _blockedBySubscription?.cancel();

    // ----------------------------------------------------------
    // আমি যাদের block করেছি
    // users/{myUid}/blocked_users/{targetUid}
    // ----------------------------------------------------------
    _blockedUsersSubscription = _db
        .collection('users')
        .doc(myUid.value)
        .collection('blocked_users')
        .snapshots()
        .listen(
          (snapshot) {
        _iBlockedUsers
          ..clear()
          ..addAll(snapshot.docs.map((doc) => doc.id));

        _refreshCombinedBlockedUsers();
      },
      onError: (error) {
        debugPrint('blocked_users listener error: $error');
      },
    );

    // ----------------------------------------------------------
    // যারা আমাকে block করেছে
    // users/{myUid}/blocked_by/{blockerUid}
    // ----------------------------------------------------------
    _blockedBySubscription = _db
        .collection('users')
        .doc(myUid.value)
        .collection('blocked_by')
        .snapshots()
        .listen(
          (snapshot) {
        _usersWhoBlockedMe
          ..clear()
          ..addAll(snapshot.docs.map((doc) => doc.id));

        _refreshCombinedBlockedUsers();
      },
      onError: (error) {
        debugPrint('blocked_by listener error: $error');
      },
    );
  }

  // ============================================================
  // 🔥 Merge both block directions
  // ============================================================
  void _refreshCombinedBlockedUsers() {
    final combined = <String>{
      ..._iBlockedUsers,
      ..._usersWhoBlockedMe,
    };

    blockedUsers.assignAll(combined);
  }

  // ============================================================
  // Extra final block verification
  // ============================================================
  Future<bool> hasBlockBetween(String targetUid) async {
    if (myUid.value.isEmpty || targetUid.isEmpty) {
      return true;
    }

    // Local reactive list first
    if (blockedUsers.contains(targetUid)) {
      return true;
    }

    // Firestore final verification
    return BlockService.hasBlockBetween(
      myUid.value,
      targetUid,
    );
  }

  // ============================================================
  // Search Toggle
  // ============================================================
  void toggleSearch() {
    isSearching.value = !isSearching.value;

    if (!isSearching.value) {
      searchController.clear();
      searchQuery.value = '';
    }
  }

  // ============================================================
  // 🔥 Inbox Stream with Mutual Block Filtering
  // ============================================================
  Stream<List<QueryDocumentSnapshot>> getInboxStream() {
    return _db
        .collection('chat_rooms')
        .where(
      'participants',
      arrayContains: myUid.value,
    )
        .snapshots()
        .asyncMap((snapshot) async {
      final List<QueryDocumentSnapshot> validDocs = [];

      for (final doc in snapshot.docs) {
        final roomData =
            doc.data() as Map<String, dynamic>? ?? {};

        final List<dynamic> participants =
            roomData['participants'] ?? [];

        final targetUid = participants
            .map((e) => e.toString())
            .firstWhere(
              (id) => id != myUid.value,
          orElse: () => '',
        );

        if (targetUid.isEmpty) {
          continue;
        }

        // Local list দিয়ে fast check
        if (blockedUsers.contains(targetUid)) {
          continue;
        }

        // Final mutual Firestore verification
        final isBlocked =
        await BlockService.hasBlockBetween(
          myUid.value,
          targetUid,
        );

        if (!isBlocked) {
          validDocs.add(doc);
        }
      }

      return validDocs;
    });
  }

  // ============================================================
  // Chat Messages Stream
  // ============================================================
  Stream<QuerySnapshot> getChatMessages(String roomId) {
    return _db
        .collection('chat_rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy(
      'timestamp',
      descending: true,
    )
        .snapshots();
  }

  // ============================================================
  // Time Ago
  // ============================================================
  String getTimeAgo(dynamic timeData) {
    if (timeData == null) {
      return 'Just now';
    }

    DateTime date;

    if (timeData is Timestamp) {
      date = timeData.toDate();
    } else if (timeData is int) {
      date =
          DateTime.fromMillisecondsSinceEpoch(timeData);
    } else {
      return 'Just now';
    }

    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) {
      return 'Just now';
    }

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }

    if (diff.inDays == 1) {
      return 'Yesterday';
    }

    if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    }

    if (diff.inDays >= 30 &&
        diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}mo ago';
    }

    if (diff.inDays >= 365) {
      return '${(diff.inDays / 365).floor()}y ago';
    }

    return 'Just now';
  }

  // ============================================================
  // Message Time
  // ============================================================
  String formatMessageTime(dynamic timeData) {
    if (timeData == null) {
      return 'Sending...';
    }

    DateTime date;

    if (timeData is Timestamp) {
      date = timeData.toDate();
    } else if (timeData is int) {
      date =
          DateTime.fromMillisecondsSinceEpoch(timeData);
    } else {
      return '';
    }

    int hour = date.hour;
    final minute = date.minute;

    final ampm = hour >= 12 ? 'PM' : 'AM';

    hour = hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    final minStr =
    minute < 10 ? '0$minute' : '$minute';

    return '$hour:$minStr $ampm';
  }

  // ============================================================
  // 🔥 Send Message
  // ============================================================
  Future<void> sendMessage(
      String roomId,
      String targetUid,
      String targetName,
      String targetAvatar,
      ) async {
    final text = messageController.text.trim();

    if (text.isEmpty ||
        myUid.value.isEmpty ||
        targetUid.isEmpty) {
      return;
    }

    // ----------------------------------------------------------
    // Content moderation
    // ----------------------------------------------------------
    final moderationResult =
    ContentFilterService.validate(text);

    if (!moderationResult.isAllowed) {
      Get.snackbar(
        'Message Blocked 🛑',
        moderationResult.reason,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

      return;
    }

    // ----------------------------------------------------------
    // 🔥 Final mutual block check
    // ----------------------------------------------------------
    final isBlocked =
    await hasBlockBetween(targetUid);

    if (isBlocked) {
      Get.snackbar(
        'Action Denied',
        'You cannot send messages to this user right now.',
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      return;
    }

    final exactTime =
        DateTime.now().millisecondsSinceEpoch;

    try {
      final batch = _db.batch();

      final messageRef = _db
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .doc();

      batch.set(
        messageRef,
        {
          'senderId': myUid.value,
          'text': text,
          'timestamp': exactTime,
          'type': 'text',
        },
      );

      final roomRef = _db
          .collection('chat_rooms')
          .doc(roomId);

      batch.set(
        roomRef,
        {
          'participants': FieldValue.arrayUnion([
            myUid.value,
            targetUid,
          ]),
          'lastMessage': text,
          'lastUpdated': exactTime,
          'usersData': {
            myUid.value: {
              'name': myName.value.isNotEmpty
                  ? myName.value
                  : 'User',
              'avatar': myAvatar.value,
            },
            targetUid: {
              'name': targetName.isNotEmpty
                  ? targetName
                  : 'User',
              'avatar': targetAvatar,
            },
          },
        },
        SetOptions(merge: true),
      );

      await batch.commit();

      // Success হলে তারপর input clear
      messageController.clear();
    } catch (e) {
      debugPrint('sendMessage error: $e');

      Get.snackbar(
        'Error',
        'Failed to send message. Please try again.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // ============================================================
  // Cleanup
  // ============================================================
  @override
  void onClose() {
    _blockedUsersSubscription?.cancel();
    _blockedBySubscription?.cancel();

    messageController.dispose();
    searchController.dispose();

    super.onClose();
  }
}