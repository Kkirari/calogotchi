import 'package:flutter/material.dart';

class BodyFatPage extends StatefulWidget {
  final Function(double) onSubmitted;
  const BodyFatPage({super.key, required this.onSubmitted});

  @override
  State<BodyFatPage> createState() => _BodyFatPageState();
}

class _BodyFatPageState extends State<BodyFatPage> {
  double _bodyFat = 20;

  // ฟังก์ชันเลือกไอคอนตาม body fat %
  IconData _getBodyIcon() {
    if (_bodyFat < 10) return Icons.accessibility_new; // Very lean
    if (_bodyFat < 15) return Icons.directions_run; // Athletic
    if (_bodyFat < 20) return Icons.person; // Normal
    if (_bodyFat < 25) return Icons.person_outline; // Slightly over
    if (_bodyFat < 30) return Icons.accessibility; // Overweight
    return Icons.airline_seat_recline_extra; // High body fat
  }

  // สีตาม body fat %
  Color _getBodyColor() {
    if (_bodyFat < 10) return const Color(0xFF00d2ff); // Cyan - very lean
    if (_bodyFat < 15) return const Color(0xFF4A90E2); // Blue - athletic
    if (_bodyFat < 20) return const Color(0xFF6c5ce7); // Purple - normal
    if (_bodyFat < 25) return const Color(0xFFffa502); // Orange - slightly over
    if (_bodyFat < 30)
      return const Color(0xFFff6348); // Red orange - overweight
    return const Color(0xFFe74c3c); // Red - high
  }

  // คำอธิบายสถานะ
  String _getBodyStatus() {
    if (_bodyFat < 10) return 'Very Lean';
    if (_bodyFat < 15) return 'Athletic';
    if (_bodyFat < 20) return 'Fit';
    if (_bodyFat < 25) return 'Average';
    if (_bodyFat < 30) return 'Above Average';
    return 'High';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Body Fat',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                ),
              ),
              const Text(
                'Percentage',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Optional',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 60),
              Expanded(
                child: Row(
                  children: [
                    // ไอคอนด้านซ้าย
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _getBodyColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getBodyColor(),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getBodyIcon(),
                                size: 80,
                                color: _getBodyColor(),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _getBodyStatus(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _getBodyColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Wheel picker ด้านขวา
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Highlight box ตรงกลาง
                            Container(
                              height: 80,
                              width: 120,
                              decoration: BoxDecoration(
                                color: _getBodyColor().withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getBodyColor(),
                                  width: 2,
                                ),
                              ),
                            ),
                            // Wheel picker
                            SizedBox(
                              height: 300,
                              child: ListWheelScrollView.useDelegate(
                                controller: FixedExtentScrollController(
                                  initialItem: 15, // 20 - 5 = index 15
                                ),
                                itemExtent: 80,
                                perspective: 0.003,
                                diameterRatio: 1.5,
                                physics: const FixedExtentScrollPhysics(),
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    _bodyFat = (index + 5).toDouble();
                                    widget.onSubmitted(_bodyFat);
                                  });
                                },
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    if (index < 0 || index > 45) return null;
                                    final bodyFat = index + 5;
                                    final isSelected =
                                        bodyFat == _bodyFat.round();

                                    return Center(
                                      child: Text(
                                        '$bodyFat',
                                        style: TextStyle(
                                          fontSize: isSelected ? 48 : 28,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: 46, // 5-50%
                                ),
                              ),
                            ),
                            // Label "%"
                            Positioned(
                              right: 10,
                              child: Text(
                                '%',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
