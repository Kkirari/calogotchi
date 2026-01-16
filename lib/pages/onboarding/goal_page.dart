import 'package:flutter/material.dart';

class GoalPage extends StatefulWidget {
  final Function(String, double) onSelected;
  const GoalPage({super.key, required this.onSelected});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  // ตั้งค่าเริ่มต้นให้ตรงกับที่ต้องการ
  String _selectedGoal = 'Maintain Weight';
  double _percentage = 10.0;

  @override
  void initState() {
    super.initState();
    // ส่งค่า default ไปให้หน้าหลักทันทีที่โหลดหน้า
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSelected(_selectedGoal, _percentage);
      print(
        "LOG: GoalPage Init - Default set to: $_selectedGoal, $_percentage%",
      );
    });
  }

  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'Lose Weight',
      'subtitle': 'Burn fat and get leaner',
      'icon': Icons.trending_down,
      'color': const Color(0xFFFFB300), // เหลืองทอง
      'imagePath': 'assets/action/lossfat.png',
      'hasSlider': true,
    },
    {
      'title': 'Maintain Weight',
      'subtitle': 'Keep your current physique',
      'icon': Icons.remove,
      'color': const Color(0xFFFFC107), // เหลืองสด
      'imagePath': 'assets/action/maintain.png',
      'hasSlider': false,
    },
    {
      'title': 'Gain Muscle',
      'subtitle': 'Build strength and mass',
      'icon': Icons.trending_up,
      'color': const Color(0xFFFFD54F), // เหลืองอ่อน
      'imagePath': 'assets/action/muscle.png',
      'hasSlider': true,
    },
  ];

  String _getDifficultyText() {
    if (_percentage <= 10) return 'Easy';
    if (_percentage <= 15) return 'Moderate';
    if (_percentage <= 20) return 'Challenging';
    return 'Very Hard';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5), // พื้นหลังขาวนวลอมเหลือง
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "What is your",
                style: TextStyle(
                  fontSize: 32,
                  color: Color(0xFF8D6E63), // น้ำตาลอ่อน
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Text(
                "Primary Goal?",
                style: TextStyle(
                  fontSize: 42,
                  color: Color(0xFF5D4037), // น้ำตาลเข้ม
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: _goals.length,
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    final isSelected = _selectedGoal == goal['title'];
                    final hasSlider = goal['hasSlider'] as bool;

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedGoal = goal['title'];
                              // ถ้าเลือก Maintain ให้รีเซ็ตเปอร์เซ็นต์เป็น 0 หรือค่าที่ต้องการ
                              if (!hasSlider)
                                _percentage = 0.0;
                              else if (_percentage == 0)
                                _percentage = 10.0;
                            });
                            widget.onSelected(_selectedGoal, _percentage);
                            print(
                              "LOG: Goal Selected - $_selectedGoal, Percent: $_percentage%",
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? goal['color'].withOpacity(0.15)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? goal['color']
                                    : const Color(0xFFE0E0E0),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? goal['color'].withOpacity(0.3)
                                      : Colors.black.withOpacity(0.05),
                                  blurRadius: isSelected ? 12 : 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        goal['color'].withOpacity(0.2),
                                        goal['color'].withOpacity(0.05),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      goal['imagePath'],
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              goal['icon'],
                                              color: goal['color'],
                                              size: 36,
                                            );
                                          },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        goal['title'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? const Color(0xFF5D4037)
                                              : const Color(0xFF757575),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        goal['subtitle'],
                                        style: const TextStyle(
                                          color: Color(0xFF9E9E9E),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: goal['color'],
                                    size: 28,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Slider Section
                        if (isSelected && hasSlider)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: goal['color'].withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: goal['color'].withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Intensity Level',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF757575),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: goal['color'].withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${_percentage.round()}%',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: goal['color'],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 6,
                                    activeTrackColor: goal['color'],
                                    inactiveTrackColor: const Color(0xFFE0E0E0),
                                    thumbColor: goal['color'],
                                    overlayColor: goal['color'].withOpacity(
                                      0.2,
                                    ),
                                  ),
                                  child: Slider(
                                    value: _percentage < 5 ? 5 : _percentage,
                                    min: 5,
                                    max: 25,
                                    divisions: 20,
                                    onChanged: (value) {
                                      setState(() {
                                        _percentage = value;
                                      });
                                      widget.onSelected(
                                        _selectedGoal,
                                        _percentage,
                                      );
                                      print(
                                        "LOG: Percent Slider Changed - $_percentage%",
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '5%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9E9E9E),
                                      ),
                                    ),
                                    Text(
                                      _getDifficultyText(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: goal['color'],
                                      ),
                                    ),
                                    const Text(
                                      '25%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9E9E9E),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
