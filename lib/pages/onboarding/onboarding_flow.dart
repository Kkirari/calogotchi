import 'package:calogotchi/pages/display_page.dart';
import 'package:calogotchi/services/user_prefs.dart';
import 'package:flutter/material.dart';
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

  // เก็บข้อมูลชั่วคราว
  final Map<String, dynamic> _userData = {};

  void _nextPage() async {
    if (_currentPage < 5) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // save data
      await UserPrefs.saveUserData(_userData);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DisplayPage()),
      );
    }
  }

  void _saveField(String key, dynamic value) {
    _userData[key] = value;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      GenderPage(onSelected: (val) => _saveField('gender', val)),
      AgePage(onSubmitted: (val) => _saveField('age', val)),
      WeightPage(onSubmitted: (val) => _saveField('weight', val)),
      HeightPage(onSubmitted: (val) => _saveField('height', val)),
      ActivityPage(onSelected: (val) => _saveField('activity', val)),
      BodyFatPage(onSubmitted: (val) => _saveField('bodyfat', val)),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _currentPage = i),
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _userData['gender'] == 'Male'
                    ? const Color(0xFF4A90E2)
                    : _userData['gender'] == 'Female'
                    ? const Color(0xFFE91E63)
                    : const Color.fromARGB(255, 54, 56, 184),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                _currentPage == pages.length - 1 ? 'Finish' : 'Continue',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
