class TdeeCalculator {
  static double calculate({
    required String gender,
    required int age,
    required double weight,
    required double height,
    required String activity,
    double bodyfat = 0.0,
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

    return bmr * factor;
  }
}
