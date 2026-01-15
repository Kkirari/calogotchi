import 'package:calogotchi/pages/onboarding/onboarding_flow.dart';
import 'package:flutter/material.dart';
import 'pages/display_page.dart';
import 'services/user_prefs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Counter',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Map<String, dynamic>?>(
        future: UserPrefs.loadUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data == null) {
            return const OnboardingFlow();
          } else {
            return const DisplayPage();
          }
        },
      ),
    );
  }
}
