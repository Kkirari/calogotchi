class TdeeCalculator {
  static Map<String, double> calculate({
    required String gender,
    required int age,
    required double weight,
    required double height,
    required String activity,
    double bodyfat = 0.0,
    required String goal,
    required double goalPercentage,
  }) {
    double bmr;
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

    double finalTdee = maintenanceTdee;
    if (goal == 'Lose Weight') {
      finalTdee = maintenanceTdee - (maintenanceTdee * (goalPercentage / 100));
    } else if (goal == 'Gain Muscle') {
      finalTdee = maintenanceTdee + (maintenanceTdee * (goalPercentage / 100));
    }

    // Macro Split
    double proteinPerKg = (goal == 'Gain Muscle') ? 2.2 : 1.8;
    double proteinGrams = proteinPerKg * weight;
    double proteinCalories = proteinGrams * 4;

    double fatCalories = finalTdee * 0.25;
    double fatGrams = fatCalories / 9;

    double carbCalories = finalTdee - (proteinCalories + fatCalories);
    double carbGrams = carbCalories / 4;

    return {
      'TDEE': finalTdee,
      'Protein': proteinGrams,
      'Fat': fatGrams,
      'Carbs': carbGrams,
    };
  }
}
