class TdeeCalculator {
  static double calculate({
    required String gender,
    required int age,
    required double weight,
    required double height,
    required String activity,
    double bodyfat = 0.0,
    required String goal, // เพิ่มตัวแปรเป้าหมาย
    required double goalPercentage, // เพิ่ม % ความเข้มข้น
  }) {
    double bmr;
    // 1. คำนวณ BMR (สูตรเดิมของคุณ)
    if (bodyfat > 0) {
      final leanMass = weight * (1 - bodyfat / 100);
      bmr = 370 + (21.6 * leanMass);
    } else {
      if (gender == 'Male') {
        bmr = 10 * weight + 6.25 * height - 5 * age + 5;
      } else {
        bmr = 10 * weight + 6.25 * height - 5 * age - 161;
      }
    }

    // 2. คำนวณ Maintenance Calories (TDEE พื้นฐาน)
    double factor = 1.2;
    switch (activity) {
      case 'Lightly Active':
        factor = 1.375;
        break;
      case 'Moderately Active':
        factor = 1.55;
        break;
      case 'Very Active':
        factor = 1.725;
        break;
    }
    double maintenanceTdee = bmr * factor;

    // 3. ปรับแต่งตามเป้าหมาย (Goal Adjustment)
    double finalTdee = maintenanceTdee;
    if (goal == 'Lose Weight') {
      // ลดพลังงานลงตาม % (Caloric Deficit)
      finalTdee = maintenanceTdee - (maintenanceTdee * (goalPercentage / 100));
    } else if (goal == 'Gain Muscle') {
      // เพิ่มพลังงานขึ้นตาม % (Caloric Surplus)
      finalTdee = maintenanceTdee + (maintenanceTdee * (goalPercentage / 100));
    }

    return finalTdee;
  }
}
