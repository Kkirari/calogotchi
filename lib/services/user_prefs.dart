import 'package:shared_preferences/shared_preferences.dart';

class UserPrefs {
  static Future<void> saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    for (var entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is int) await prefs.setInt(key, value);
      if (value is double) await prefs.setDouble(key, value);
      if (value is String) await prefs.setString(key, value);
    }
  }

  static Future<Map<String, dynamic>?> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // เช็คว่ามีข้อมูลพื้นฐานไหม ถ้าไม่มีให้ถือว่ายังไม่ได้ทำ Onboarding
    if (!prefs.containsKey('gender')) return null;

    return {
      'gender': prefs.getString('gender'),
      'age': prefs.getInt('age'),
      'weight': prefs.getDouble('weight'),
      'height': prefs.getDouble('height'),
      'activity': prefs.getString('activity'),
      'bodyfat': prefs.getDouble('bodyfat'),
      'goal': prefs.getString('goal'), // เพิ่มใหม่
      'goalPercentage': prefs.getDouble('goalPercentage'), // เพิ่มใหม่
      'tdee': prefs.getDouble('tdee'),
    };
  }
}
