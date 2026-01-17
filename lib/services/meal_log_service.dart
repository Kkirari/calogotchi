import 'package:Calogotchi/services/meal_log.dart';
import 'package:hive/hive.dart';

class MealLogService {
  static Future<void> addMeal(MealLog log) async {
    final box = await Hive.openBox('meal_logs');
    await box.put(log.id, log.toMap());
  }

  static Future<List<MealLog>> getMealsByDate(DateTime date) async {
    final box = await Hive.openBox('meal_logs');
    return box.values
        .map((e) => MealLog.fromMap(Map<String, dynamic>.from(e)))
        .where(
          (log) =>
              log.date.year == date.year &&
              log.date.month == date.month &&
              log.date.day == date.day,
        )
        .toList();
  }
}
