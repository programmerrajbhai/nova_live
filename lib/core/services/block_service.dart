import 'package:cloud_firestore/cloud_firestore.dart';

class BlockService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // চেক করবে আমি কাউকে ব্লক করেছি কিনা
  static Future<bool> iBlocked(String myUid, String targetUid) async {
    if (myUid.isEmpty || targetUid.isEmpty) return true; // Fail-safe
    try {
      final doc = await _db
          .collection('users')
          .doc(myUid)
          .collection('blocked_users')
          .doc(targetUid)
          .get();
      return doc.exists;
    } catch (e) {
      return true; // এরর হলে সিকিউরিটির জন্য ব্লক হিসেবেই ধরবে
    }
  }

  // চেক করবে সে আমাকে ব্লক করেছে কিনা
  static Future<bool> theyBlockedMe(String myUid, String targetUid) async {
    if (myUid.isEmpty || targetUid.isEmpty) return true; // Fail-safe
    try {
      final doc = await _db
          .collection('users')
          .doc(myUid)
          .collection('blocked_by')
          .doc(targetUid)
          .get();
      return doc.exists;
    } catch (e) {
      return true; // Fail-closed
    }
  }

  // দুজনের মধ্যে কোনো ব্লক সম্পর্ক আছে কিনা (যেকোনো একদিক থেকে)
  static Future<bool> hasBlockBetween(String myUid, String targetUid) async {
    if (myUid.isEmpty || targetUid.isEmpty) return true;
    try {
      bool blocked1 = await iBlocked(myUid, targetUid);
      if (blocked1) return true;

      bool blocked2 = await theyBlockedMe(myUid, targetUid);
      return blocked2;
    } catch (e) {
      return true;
    }
  }
}