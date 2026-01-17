import 'package:Calogotchi/services/meal_log.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart'; // ✅ ต้อง import ตัวนี้เพื่อใช้ ValueNotifier

class MealLogService {
  // ✅ 1. เพิ่ม Notifier ตัวนี้สำหรับแจ้งเตือนการเปลี่ยนแปลงข้อมูล
  static final ValueNotifier<int> refreshTrigger = ValueNotifier<int>(0);

  static Future<void> addMeal(MealLog log) async {
    final box = await Hive.openBox('meal_logs');
    await box.put(log.id, log.toMap());

    // ✅ 2. ดีดตัวเลขขึ้น 1 เพื่อส่งสัญญาณบอกผู้ที่ฟังอยู่ (เช่น หน้า History) ให้ Refresh
    refreshTrigger.value++;

    print("🔔 Signal sent: Data Updated (${refreshTrigger.value})");
  }

  static Future<List<MealLog>> getMealsByDate(DateTime date) async {
    final box = await Hive.openBox('meal_logs');

    // ดึงข้อมูลและกรองตามวันที่
    final meals = box.values
        .map((e) => MealLog.fromMap(Map<String, dynamic>.from(e)))
        .where(
          (log) =>
              log.date.year == date.year &&
              log.date.month == date.month &&
              log.date.day == date.day,
        )
        .toList();

    // เรียงลำดับตามเวลา (จากใหม่ไปเก่า) ให้ด้วยเพื่อความสวยงาม
    meals.sort((a, b) => b.date.compareTo(a.date));

    return meals;
  }
}
