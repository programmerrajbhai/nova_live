import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ZegoConfigController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var appId = 0.obs;
  var appSign = ''.obs;
  var isConfigLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToZegoConfig();
  }

  void _listenToZegoConfig() {
    _db.collection('settings').doc('zego_config').snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        appId.value = doc.data()!['app_id'] ?? 0;
        appSign.value = doc.data()!['app_sign'] ?? '';
        isConfigLoaded.value = true;
      }
    }, onError: (error) {
      debugPrint("Error fetching Zego Config: $error");
    });
  }
}