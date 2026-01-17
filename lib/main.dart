import 'package:Calogotchi/pages/main_wrapper.dart';
import 'package:Calogotchi/pages/onboarding/onboarding_flow.dart';
import 'package:flutter/material.dart';
import 'services/user_prefs.dart';

import 'package:hive_flutter/hive_flutter.dart'; // ✅ import นี้

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // เช็คว่ามีข้อมูลในเครื่องไหม
  final userData = await UserPrefs.loadUserData();
  await Hive.initFlutter();

  runApp(MyApp(showOnboarding: userData == null));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // ถ้าไม่มีข้อมูลให้ไป Onboarding ถ้ามีแล้วให้ไปหน้าหลัก (MainWrapper)
      home: showOnboarding ? const OnboardingFlow() : const MainWrapper(),
    );
  }
}
