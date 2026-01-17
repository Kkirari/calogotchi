import 'package:flutter/material.dart';
import 'package:Calogotchi/components/dashboard.dart';
import 'package:Calogotchi/components/animation_player.dart'; // ✅ import component

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  String _getFormattedDate() {
    DateTime now = DateTime.now();
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return "${now.day} ${months[now.month - 1]} ${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(
          255,
          255,
          249,
          230,
        ).withOpacity(0.95),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getFormattedDate(),
              style: const TextStyle(color: Color(0xFF5D4037), fontSize: 14),
            ),
            const Text(
              "Dashboard",
              style: TextStyle(
                color: Color(0xFF5D4037),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF5D4037)),
      ),
      body: Stack(
        children: [
          // --- Layer 1: Video Background ---
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            bottom: 0,
            child: const AnimationPlayer(
              assetPath: 'assets/animation/idle.mp4', // ✅ ใช้ path ได้ง่าย
            ),
          ),

          // --- Layer 2: Dashboard Bar ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(bottom: false, child: const DashboardBar()),
          ),

          // --- Layer 3: Bottom UI Content ---
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Idle Mode',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.black,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
