import 'dart:io';
import 'package:Calogotchi/services/ai_cal_calulate.dart';
import 'package:Calogotchi/services/meal_log.dart';
import 'package:Calogotchi/services/meal_log_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class AnalysisResultPage extends StatefulWidget {
  final String imagePath;
  final String mode;

  const AnalysisResultPage({
    super.key,
    required this.imagePath,
    required this.mode,
  });

  @override
  State<AnalysisResultPage> createState() => _AnalysisResultPageState();
}

class _AnalysisResultPageState extends State<AnalysisResultPage> {
  final AICalculateService _aiService = AICalculateService();
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _nutritionData;

  @override
  void initState() {
    super.initState();
    _processData();
  }

  Future<void> _processData() async {
    final result = await _aiService.analyzeFoodImage(
      widget.imagePath,
      widget.mode,
    );
    setState(() {
      _nutritionData = result;
      _isLoading = false;
    });
  }

  Future<void> _saveMealLog() async {
    if (_nutritionData == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      // สร้าง MealLog จากข้อมูล AI
      final mealLog = MealLog(
        id: const Uuid().v4(),
        date: DateTime.now(),
        name: _nutritionData!['food_name'] ?? 'Unknown Food',
        calories:
            double.tryParse(_nutritionData!['calories'].toString()) ?? 0.0,
        protein: double.tryParse(_nutritionData!['protein'].toString()) ?? 0.0,
        fat: double.tryParse(_nutritionData!['fat'].toString()) ?? 0.0,
        carbs: double.tryParse(_nutritionData!['carbs'].toString()) ?? 0.0,
        imagePath: widget.imagePath,
      );

      print('💾 Saving meal log:');
      print('   Name: ${mealLog.name}');
      print('   Calories: ${mealLog.calories}');
      print(
        '   P: ${mealLog.protein}g, F: ${mealLog.fat}g, C: ${mealLog.carbs}g',
      );

      await MealLogService.addMeal(mealLog);
      print('✅ Meal saved successfully!');

      if (!mounted) return;

      // แสดง success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Meal saved successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      // รอให้เห็น snackbar แล้วกลับไปหน้าหลัก
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // กลับไปหน้า desktop โดยปิดทุกหน้าที่เปิดมา (กล้อง + result)
      Navigator.of(context).popUntil((route) => route.isFirst);

      // หรือถ้าต้องการกลับไปหน้าที่มี bottom navigation bar
      // Navigator.of(context).pop(); // ปิดหน้า result
      // Navigator.of(context).pop(); // ปิดหน้ากล้อง
    } catch (e) {
      print('❌ Error saving meal: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Text('Error: ${e.toString()}'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: Text(
          widget.mode == 'ai' ? 'AI Analysis' : 'Nutrition Label',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF5D4037),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF5D4037)),
      ),
      body: _isLoading ? _buildLoadingUI() : _buildResultUI(),
    );
  }

  Widget _buildLoadingUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 40),
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: Color(0xFF5D4037),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '🔍 Analyzing your food...',
            style: TextStyle(
              color: Color(0xFF5D4037),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.mode == 'ai'
                ? 'AI is identifying ingredients'
                : 'Reading nutrition label',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildResultUI() {
    if (_nutritionData == null || _nutritionData!.containsKey('error')) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('❌', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 20),
              Text(
                _nutritionData?['error'] ?? 'Analysis Failed',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D4037),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Image Card
          Container(
            height: 220,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
            ),
          ),

          // Food Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  _nutritionData!['food_name'].toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF5D4037),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Calories Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6D4C41), Color(0xFF5D4037)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5D4037).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Calories',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 8),
                          Text(
                            _nutritionData!['calories'].toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'kcal',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Macros Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildMacroCard(
                        '💪',
                        'Protein',
                        '${_nutritionData!['protein']}g',
                        const Color(0xFFEF5350),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMacroCard(
                        '💧',
                        'Fat',
                        '${_nutritionData!['fat']}g',
                        const Color(0xFFFF9800),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildMacroCard(
                        '🍚',
                        'Carbs',
                        '${_nutritionData!['carbs']}g',
                        const Color(0xFF42A5F5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMacroCard(
                        '🍬',
                        'Sugar',
                        '${_nutritionData!['sugar']}g',
                        const Color(0xFFEC407A),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Description
                if (_nutritionData!['description'] != null)
                  _buildInfoCard(
                    'Analysis Summary',
                    _nutritionData!['description'],
                    Icons.analytics,
                  ),

                const SizedBox(height: 12),

                // Health Tips
                if (_nutritionData!['health_tips'] != null)
                  _buildInfoCard(
                    'Nutrition Guidance',
                    _nutritionData!['health_tips'],
                    Icons.lightbulb_outline,
                  ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.pop(context),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Scan Again'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF5D4037),
                          side: const BorderSide(
                            color: Color(0xFF5D4037),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveMealLog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5D4037),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, size: 20),
                                  SizedBox(width: 8),
                                  Text('Save Meal'),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(
    String emoji,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5D4037),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF5D4037)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF5D4037),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
