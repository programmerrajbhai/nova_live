import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
// 🔥 ZegoCloud এর গ্লোবাল প্লাগিন ইম্পোর্ট
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import 'features/splash/splash_view.dart'; // আপনার স্প্ল্যাশ স্ক্রিনের ইম্পোর্ট ঠিক রাখবেন

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ফায়ারবেস ইনিশিয়ালাইজেশন
  await Firebase.initializeApp();

  // 🔥 MASTER FIX: অ্যাপ ওপেন হওয়ার সাথেই Signaling (ZIM) প্লাগিন চালু করা হলো।
  // এর ফলে অডিও রুমের সিট নিয়ে আর কখনোই '6000212' এরর আসবে না।
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