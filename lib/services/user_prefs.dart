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
    if (!prefs.containsKey('gender')) return null;
    return {
      'gender': prefs.getString('gender'),
      'age': prefs.getInt('age'),
      'weight': prefs.getDouble('weight'),
      'height': prefs.getDouble('height'),
      'activity': prefs.getString('activity'),
      'bodyfat': prefs.getDouble('bodyfat'),
      'tdee': prefs.getDouble('tdee'),
    };
  }
}
