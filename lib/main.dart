import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'features/splash/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase app চালুর জন্য প্রয়োজন, তাই এটি আগে initialize হবে।
  await Firebase.initializeApp();

  // 🔥 ২১ নম্বর সমস্যা ফিক্স: ZegoUIKit().installPlugins এখান থেকে রিমুভ করা হলো।
  // এটি ActiveAudioRoomView-তে অটোমেটিকভাবে ইনিশিয়ালাইজ হবে, ফলে ডাবল ইনিশিয়ালাইজেশন কনফ্লিক্ট হবে না।

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