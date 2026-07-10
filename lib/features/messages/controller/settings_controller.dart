import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  var myUid = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUid();
  }

  Future<void> _loadUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    myUid.value = prefs.getString('uid') ?? '';
  }

  // 🚫 Blocked Users Stream
  Stream<QuerySnapshot> getBlockedUsers() {
    return _db.collection('users').doc(myUid.value).collection('blocked_users').snapshots();
  }

  // 🚩 Reported Users Stream
  Stream<QuerySnapshot> getReportedUsers() {
    return _db.collection('reports').where('reporterId', isEqualTo: myUid.value).snapshots();
  }

  // ✅ Unblock User Function
  Future<void> unblockUser(String blockedUserId, String userName) async {
    try {
      await _db.collection('users').doc(myUid.value).collection('blocked_users').doc(blockedUserId).delete();
      Get.snackbar('Unblocked', '$userName has been unblocked successfully.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to unblock: $e');
    }
  }

  // ↩️ Undo Report Function
  Future<void> undoReport(String reportId) async {
    try {
      await _db.collection('reports').doc(reportId).delete();
      Get.snackbar('Report Canceled', 'Your report has been undone.', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel report: $e');
    }
  }
}