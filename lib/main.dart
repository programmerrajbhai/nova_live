import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// 🔥 ZegoCloud Signaling Plugin
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

// আপনার অ্যাপের অন্যান্য পেজ ইম্পোর্ট
import 'features/splash/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ফায়ারবেস ইনিশিয়ালাইজেশন
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  // 🔥 মাস্টার ফিক্স ১: অ্যাপের শুরুতেই সিগনালিং ইঞ্জিন ইন্সটল করে দিলাম
  ZegoUIKit().installPlugins([ZegoUIKitSignalingPlugin()]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Nova Live',
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