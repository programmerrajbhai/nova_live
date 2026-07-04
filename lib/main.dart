// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'features/onboarding/view/onboarding_view.dart';

void main() {
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
      home: OnboardingView(), // সরাসরি ভিউ কল করা হলো
    );
  }
}