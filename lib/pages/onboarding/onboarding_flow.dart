import 'package:flutter/material.dart';
import 'package:calogotchi/pages/display_page.dart';
import 'package:calogotchi/services/user_prefs.dart';
import 'package:calogotchi/utils/tdee_calculator.dart';

// Import หน้าต่างๆ
import 'goal_page.dart';
import 'intro_cutscene_page.dart';
import 'gender_page.dart';
import 'age_page.dart';
import 'weight_page.dart';
import 'height_page.dart';
import 'activity_page.dart';
import 'bodyfat_page.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // เก็บข้อมูลทั้งหมดที่จะใช้คำนวณและบันทึก
  final Map<String, dynamic> _userData = {
    'goal': 'Maintain Weight',
    'goalPercentage': 10.0,
    'gender': 'Male',
    'age': 25,
    'weight': 60.0,
    'height': 170.0,
    'activity': 'Sedentary',
    'bodyfat': 0.0,
  };

  void _nextPage() async {
    if (_currentPage < 7) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // --- ขั้นตอนสุดท้าย: คำนวณ TDEE ก่อนบันทึก ---
      double finalTdee = TdeeCalculator.calculate(
        gender: _userData['gender'],
        age: _userData['age'],
        weight: _userData['weight'],
        height: _userData['height'],
        activity: _userData['activity'],
        bodyfat: _userData['bodyfat'],
        goal: _userData['goal'],
        goalPercentage: _userData['goalPercentage'],
      );

      _userData['tdee'] = finalTdee;
      await UserPrefs.saveUserData(_userData);

      print("LOG: Onboarding Finished. Calculated TDEE: $finalTdee");

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DisplayPage()),
      );
    }
  }

  void _saveField(String key, dynamic value) {
    setState(() => _userData[key] = value);
  }

  void _saveGoal(String goal, double percentage) {
    setState(() {
      _userData['goal'] = goal;
      _userData['goalPercentage'] = percentage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      GenderPage(onSelected: (val) => _saveField('gender', val)), // หน้า 0
      AgePage(onSubmitted: (val) => _saveField('age', val)), // หน้า 1
      WeightPage(onSubmitted: (val) => _saveField('weight', val)), // หน้า 2
      HeightPage(onSubmitted: (val) => _saveField('height', val)), // หน้า 3
      ActivityPage(onSelected: (val) => _saveField('activity', val)), // หน้า 4
      BodyFatPage(onSubmitted: (val) => _saveField('bodyfat', val)), // หน้า 5
      IntroCutscenePage(onFinished: _nextPage), // หน้า 6
      GoalPage(onSelected: _saveGoal), // หน้า 7
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: pages,
          ),

          // ปุ่ม Skip Intro: แสดงเฉพาะหน้า Cutscene (index 6)
          if (_currentPage == 6)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: TextButton(
                  onPressed: _nextPage,
                  child: const Text(
                    "Skip Intro",
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),

          // ปุ่ม Continue: แสดงทุกหน้าที่ไม่ใช่ Cutscene (0–5 และ 7)
          if (_currentPage != 6)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getButtonColor(),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == 7 ? 'Finish' : 'Continue',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getButtonColor() {
    if (_userData['gender'] == 'Male') {
      return const Color.fromARGB(255, 241, 181, 0);
    }
    if (_userData['gender'] == 'Female') {
      return const Color.fromARGB(255, 241, 181, 0);
    }
    return const Color(0xFF6c5ce7);
  }
}
