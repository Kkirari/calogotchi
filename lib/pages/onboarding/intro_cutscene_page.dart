import 'dart:async';
import 'package:flutter/material.dart';

class IntroCutscenePage extends StatefulWidget {
  final VoidCallback onFinished;
  const IntroCutscenePage({super.key, required this.onFinished});

  @override
  State<IntroCutscenePage> createState() => _IntroCutscenePageState();
}

class _IntroCutscenePageState extends State<IntroCutscenePage> {
  int _currentFrame = 0;
  Timer? _timer;

  // ตรวจสอบว่า Path ตรงกับใน pubspec.yaml (ต้องไม่มี lib/ นำหน้า)
  final List<String> _frames = [
    'assets/images/scene1.png',
    'assets/images/scene2.png',
    'assets/images/scene3.png',
    'assets/images/scene4.png',
    'assets/images/scene5.png',
  ];

  final List<String> _captions = [
    "ดึกแล้ว... แต่ท้องมันร้องไม่หยุดเลย",
    "เอ๊ะ!? จู่ๆ ในกระจกก็มีมือยื่นออกมา?",
    "ตุ้บ!! ยัยตัวเล็กนี่พุ่งใส่ท้องฉันเต็มๆ", // ใส่ Sound Effect
    "เธอคือ... ปีศาจ? หรือ ตัวอะไรกันนะ?",
    "แย่แล้ว! จู่ๆ ท้องเราก็มีแสงเชื่อมกันเฉยเลย!",
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentFrame < _frames.length - 1) {
        if (mounted) setState(() => _currentFrame++);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ไม่ต้องมี Scaffold เพราะหน้า OnboardingFlow มีให้แล้ว
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: Container(
                key: ValueKey<int>(_currentFrame),
                width: 380,
                height: 620,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white10, // พื้นหลังสำรองถ้ารูปไม่ขึ้น
                  image: DecorationImage(
                    image: AssetImage(_frames[_currentFrame]),
                    fit: BoxFit.cover,
                    // ตัวช่วยเช็ค Error ถ้ารูปไม่ขึ้น
                    onError: (exception, stackTrace) =>
                        print("Error loading image: $_frames[_currentFrame]"),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _captions[_currentFrame],
                  key: ValueKey<String>(_captions[_currentFrame]),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
