import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/user_prefs.dart';
import '../services/meal_log_service.dart'; // เพิ่ม import
import '../services/meal_log.dart'; // เพิ่ม import

class DashboardBar extends StatelessWidget {
  const DashboardBar({super.key});

  @override
  Widget build(BuildContext context) {
    // ใช้ Future.wait เพื่อโหลดข้อมูล 2 อย่างพร้อมกัน
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        UserPrefs.loadUserData(),
        MealLogService.getMealsByDate(DateTime.now()), // ดึงรายการอาหารวันนี้
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFC107)),
          );
        }

        // snapshot.data[0] คือข้อมูลจาก UserPrefs
        // snapshot.data[1] คือ List<MealLog> จาก MealLogService
        final userData = snapshot.data?[0] as Map<String, dynamic>?;
        final mealLogs = snapshot.data?[1] as List<MealLog>? ?? [];

        if (userData == null) {
          return const Center(child: Text("No Data"));
        }

        // --- 1. ดึงค่าเป้าหมายจาก SharedPreferences ---
        final double targetCalories = userData['tdee'] ?? 2000.0;
        final double targetProtein = userData['protein'] ?? 150.0;
        final double targetFat = userData['fat'] ?? 65.0;
        final double targetCarbs = userData['carbs'] ?? 250.0;

        // --- 2. คำนวณค่าปัจจุบันจากรายการอาหารที่แอดมา ---
        double currentCalories = 0;
        double currentProtein = 0;
        double currentFat = 0;
        double currentCarbs = 0;

        for (var meal in mealLogs) {
          currentCalories += meal.calories;
          currentProtein += meal.protein;
          currentFat += meal.fat;
          currentCarbs += meal.carbs;
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // กราฟวงกลมแคลอรี่
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildCircularCalorieProgress(
                    currentCalories,
                    targetCalories,
                  ),
                ),

                const SizedBox(width: 35),

                // กราฟแท่งโปรตีน ไขมัน คาร์บ
                Expanded(
                  child: _buildMacroBars(
                    currentProtein,
                    targetProtein,
                    currentFat,
                    targetFat,
                    currentCarbs,
                    targetCarbs,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ส่วนอื่นๆ ของโค้ด (Painter, Helper Widgets) เหมือนเดิมได้เลยครับ...
  // (ผมรวมไว้ให้ด้านล่างเพื่อความสมบูรณ์)

  Widget _buildCircularCalorieProgress(double current, double target) {
    double progress = (current / target).clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(100, 100),
                painter: CircleProgressPainter(
                  progress: 1.0,
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 10,
                ),
              ),
              CustomPaint(
                size: const Size(100, 100),
                painter: CircleProgressPainter(
                  progress: progress,
                  color: _getCalorieColor(progress),
                  strokeWidth: 10,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    current.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  Text(
                    '/ ${target.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF5D4037).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroBars(
    double cp,
    double tp,
    double cf,
    double tf,
    double cc,
    double tc,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMacroBar(
          label: 'P',
          current: cp,
          target: tp,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 8),
        _buildMacroBar(
          label: 'F',
          current: cf,
          target: tf,
          color: Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildMacroBar(label: 'C', current: cc, target: tc, color: Colors.blue),
      ],
    );
  }

  Widget _buildMacroBar({
    required String label,
    required double current,
    required double target,
    required Color color,
  }) {
    double progress = (current / target).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.7), color],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 65,
          child: Text(
            '${current.toInt()} / ${target.toInt()}',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Color _getCalorieColor(double progress) {
    if (progress < 0.5) return Colors.green;
    if (progress < 0.8) return Colors.orange;
    if (progress < 1.0) return Colors.amber;
    return Colors.redAccent;
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  CircleProgressPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 10,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
