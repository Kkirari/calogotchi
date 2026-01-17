import 'package:Calogotchi/pages/onboarding/onboarding_flow.dart';
import 'package:flutter/material.dart';
import '../services/user_prefs.dart';
import '../utils/tdee_calculator.dart';

class DisplayPage extends StatelessWidget {
  const DisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF5D4037),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: UserPrefs.loadUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFC107)),
            );
          }

          final data = snapshot.data;
          if (data == null) return const Center(child: Text("No Data"));

          // 1. คำนวณค่า Maintenance (ค่าเดิมก่อนลด/เพิ่ม)
          final maintenanceTdee = TdeeCalculator.calculate(
            gender: data['gender'] ?? 'Male',
            age: data['age'] ?? 25,
            weight: data['weight'] ?? 60.0,
            height: data['height'] ?? 170.0,
            activity: data['activity'] ?? 'Sedentary',
            bodyfat: data['bodyfat'] ?? 0.0,
            goal: 'Maintain Weight', // บังคับเป็น Maintain เพื่อหาค่าตั้งต้น
            goalPercentage: 0.0,
          );

          // 2. คำนวณค่า Target (ค่าที่ปรับตาม Goal แล้ว)
          final targetTdee = TdeeCalculator.calculate(
            gender: data['gender'] ?? 'Male',
            age: data['age'] ?? 25,
            weight: data['weight'] ?? 60.0,
            height: data['height'] ?? 170.0,
            activity: data['activity'] ?? 'Sedentary',
            bodyfat: data['bodyfat'] ?? 0.0,
            goal: data['goal'] ?? 'Maintain Weight',
            goalPercentage: data['goalPercentage'] ?? 10.0,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // แสดงการเปรียบเทียบ TDEE
                _buildTdeeComparisonCard(
                  maintenance: maintenanceTdee,
                  target: targetTdee,
                  goal: data['goal'] ?? 'Maintain Weight',
                ),

                const SizedBox(height: 25),

                // ข้อมูลรายละเอียดอื่นๆ
                _buildInfoTile(
                  Icons.track_changes,
                  "Current Goal",
                  "${data['goal']}",
                  const Color(0xFFFFC107),
                ),
                _buildInfoTile(
                  Icons.monitor_weight,
                  "Current Weight",
                  "${data['weight']} kg",
                  Colors.green,
                ),
                _buildInfoTile(
                  Icons.height,
                  "Height",
                  "${data['height']} cm",
                  Colors.blue,
                ),
                _buildInfoTile(
                  Icons.cake,
                  "Age",
                  "${data['age']} years old",
                  Colors.orange,
                ),

                const SizedBox(height: 40),

                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const OnboardingFlow()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "Reset Profile Data",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget แสดง Card เปรียบเทียบแคลอรี่
  Widget _buildTdeeComparisonCard({
    required double maintenance,
    required double target,
    required String goal,
  }) {
    double diff = target - maintenance;
    bool isReduction = diff < 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Daily Calorie Summary",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // ฝั่งค่าปกติ
              Column(
                children: [
                  const Text(
                    "Maintenance",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${maintenance.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8D6E63),
                    ),
                  ),
                  const Text(
                    "kcal",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              // ไอคอนบ่งบอกทิศทาง
              Icon(
                isReduction ? Icons.arrow_forward : Icons.arrow_forward,
                color: Colors.grey[300],
              ),
              // ฝั่งเป้าหมาย (เด่นกว่า)
              Column(
                children: [
                  Text(
                    "Target",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isReduction ? Colors.redAccent : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${target.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isReduction ? Colors.redAccent : Colors.green,
                    ),
                  ),
                  const Text(
                    "kcal",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          // บรรทัดสรุปผลต่าง
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isReduction ? "Deficit: " : "Surplus: ",
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                "${diff.abs().toStringAsFixed(0)} kcal / day",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isReduction ? Colors.redAccent : Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF5D4037),
          ),
        ),
      ),
    );
  }
}
