// services/calories_data.dart
class CaloriesData {
  final int calories; // พลังงานรวม kcal
  final int protein; // โปรตีน (g)
  final int carbs; // คาร์โบไฮเดรต (g)
  final int fat; // ไขมัน (g)
  final int fiber; // ใยอาหาร (g)
  final int sugar; // น้ำตาล (g)
  final int sodium; // โซเดียม (mg)

  const CaloriesData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
  });

  // ✅ ตัวอย่างข้อมูลมาตรฐานต่อวัน (ค่าอ้างอิงทั่วไป)
  static const recommendedDaily = CaloriesData(
    calories: 2000,
    protein: 50,
    carbs: 275,
    fat: 70,
    fiber: 30,
    sugar: 50,
    sodium: 2300,
  );

  // ✅ ฟังก์ชันรวมค่า (เช่นเวลาบวกอาหารหลายมื้อ)
  CaloriesData operator +(CaloriesData other) {
    return CaloriesData(
      calories: calories + other.calories,
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
      fiber: fiber + other.fiber,
      sugar: sugar + other.sugar,
      sodium: sodium + other.sodium,
    );
  }

  // ✅ แปลงเป็น Map (ใช้บันทึกลง SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
    };
  }

  // ✅ สร้างจาก Map (เวลาโหลดข้อมูลกลับมา)
  factory CaloriesData.fromMap(Map<String, dynamic> map) {
    return CaloriesData(
      calories: map['calories'] ?? 0,
      protein: map['protein'] ?? 0,
      carbs: map['carbs'] ?? 0,
      fat: map['fat'] ?? 0,
      fiber: map['fiber'] ?? 0,
      sugar: map['sugar'] ?? 0,
      sodium: map['sodium'] ?? 0,
    );
  }
}
