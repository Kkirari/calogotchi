class MealLog {
  final String id;
  final DateTime date;
  final String name;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  // ✅ เพิ่มตัวแปรเก็บ Path รูปภาพ (เป็น Optional)
  final String? imagePath;

  MealLog({
    required this.id,
    required this.date,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    // ✅ เพิ่มใน Constructor (ไม่ต้องใส่ required)
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'name': name,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      // ✅ เพิ่มใน toMap
      'imagePath': imagePath,
    };
  }

  factory MealLog.fromMap(Map<String, dynamic> map) {
    return MealLog(
      id: map['id'],
      date: DateTime.parse(map['date']),
      name: map['name'],
      calories: map['calories'],
      protein: map['protein'],
      fat: map['fat'],
      carbs: map['carbs'],
      // ✅ เพิ่มใน fromMap
      imagePath: map['imagePath'],
    );
  }
}
