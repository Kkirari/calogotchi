import 'package:flutter/material.dart';
import '../services/user_prefs.dart';
import '../utils/tdee_calculator.dart';

class DisplayPage extends StatelessWidget {
  const DisplayPage({super.key});

  Future<void> _saveTDEE(double tdee) async {
    await UserPrefs.saveUserData({'tdee': tdee});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ข้อมูลของคุณ')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: UserPrefs.loadUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: Text('ยังไม่มีข้อมูล'));
          }

          final tdee = TdeeCalculator.calculate(
            gender: data['gender'],
            age: data['age'],
            weight: data['weight'],
            height: data['height'],
            activity: data['activity'],
            bodyfat: data['bodyfat'] ?? 0.0,
          );

          _saveTDEE(tdee);

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender: ${data['gender']}',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  'Age: ${data['age']} ปี',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  'Weight: ${data['weight']} กก.',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  'Height: ${data['height']} ซม.',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  'Activity: ${data['activity']}',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  'Body Fat: ${data['bodyfat']} %',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 20),
                Text(
                  'TDEE: ${tdee.toStringAsFixed(0)} kcal/day',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
