import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/splash/splash_view.dart'; // নতুন স্প্ল্যাশ স্ক্রিন

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NovaLiveApp());
}

class NovaLiveApp extends StatelessWidget {
  const NovaLiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Nova Live',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primarySwatch: Colors.deepPurple,
      ),
      // সরাসরি স্প্ল্যাশ স্ক্রিনে যাবে
      home: SplashView(),
    );
  }
}