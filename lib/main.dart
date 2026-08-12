import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// 🔥 Zego ইম্পোর্টগুলো যুক্ত করা হলো
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'features/splash/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase app চালুর জন্য প্রয়োজন, তাই এটি আগে initialize হবে।
  await Firebase.initializeApp();

  // 🔥 ১০০০% ফিক্স: Zego প্লাগিন অ্যাপ চালু হওয়ার সময় ঠিক একবারই ইনিশিয়ালাইজ হবে।
  // এতে রুমে ঢোকার সময় "user is not logged in yet" বা রেস-কন্ডিশন এরর আসবে না।
  ZegoUIKit().installPlugins([ZegoUIKitSignalingPlugin()]);

  // Firebase ready হলেই UI চালু হবে।
  runApp(const MyApp());

  // AdMob background-এ initialize হবে।
  // Ads-এর জন্য app opening আটকে থাকবে না।
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