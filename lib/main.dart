import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'features/splash/splash_view.dart';
// 🔥 আপনার ZegoConfigController ইমপোর্ট করুন
import 'core/controllers/zego_config_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // 🔥 অ্যাপ চালু হওয়ার সাথে সাথেই কন্ট্রোলারটি মেমোরিতে পার্মানেন্ট করে দিন
  Get.put(ZegoConfigController(), permanent: true);

  ZegoUIKit().installPlugins([ZegoUIKitSignalingPlugin()]);

  runApp(const MyApp());

  unawaited(_initializeAds());
}

Future<void> _initializeAds() async {
  try {
    await MobileAds.instance.initialize();
  } catch (error) {
    debugPrint('AdMob initialization error: $error');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Nova Mate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: SplashView(),
    );
  }
}