import 'package:flutter/material.dart';
import '../services/user_prefs.dart';
import '../utils/tdee_calculator.dart';

class DisplayPage extends StatelessWidget {
  const DisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e), // ธีมเดียวกับ Onboarding
      appBar: AppBar(
        title: const Text(
          'Your Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: UserPrefs.loadUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(
              child: Text(
                'No data found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          // คำนวณ TDEE ใหม่โดยรวมเป้าหมายเข้าไปด้วย
          final tdee = TdeeCalculator.calculate(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ส่วนแสดงผล TDEE ใหญ่ๆ
                _buildTdeeCard(tdee, data['goal'] ?? 'Maintain Weight'),

                const SizedBox(height: 30),
                const Text(
                  "User Details",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                // ข้อมูลเป้าหมาย
                _buildInfoTile(
                  Icons.track_changes,
                  "Goal",
                  "${data['goal']} (${data['goalPercentage']?.round() ?? 0}%)",
                  Colors.orangeAccent,
                ),

                // ข้อมูลร่างกาย
                _buildInfoTile(
                  Icons.person,
                  "Gender",
                  data['gender'],
                  Colors.blueAccent,
                ),
                _buildInfoTile(
                  Icons.cake,
                  "Age",
                  "${data['age']} years old",
                  Colors.purpleAccent,
                ),
                _buildInfoTile(
                  Icons.monitor_weight,
                  "Weight",
                  "${data['weight']} kg",
                  Colors.greenAccent,
                ),
                _buildInfoTile(
                  Icons.height,
                  "Height",
                  "${data['height']} cm",
                  Colors.cyanAccent,
                ),
                _buildInfoTile(
                  Icons.directions_run,
                  "Activity",
                  data['activity'],
                  Colors.yellowAccent,
                ),
                _buildInfoTile(
                  Icons.percent,
                  "Body Fat",
                  data['bodyfat'] > 0 ? "${data['bodyfat']}%" : "Unknown",
                  Colors.redAccent,
                ),

                const SizedBox(height: 40),

                // ปุ่มกลับไปแก้ไข (ถ้าต้องการ)
                Center(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(), // หรือ Navigate ไปหน้า Onboarding ใหม่
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white54,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Edit Information"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget สำหรับแสดงบัตร TDEE
  Widget _buildTdeeCard(double tdee, String goal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF6c5ce7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6c5ce7).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "DAILY TARGET",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${tdee.toStringAsFixed(0)} kcal",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              goal.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget สำหรับแสดงแถวข้อมูลแต่ละอัน
  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
