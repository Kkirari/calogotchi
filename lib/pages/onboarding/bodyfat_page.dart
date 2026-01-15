import 'package:flutter/material.dart';

class BodyFatPage extends StatefulWidget {
  final Function(double) onSubmitted;
  const BodyFatPage({super.key, required this.onSubmitted});

  @override
  State<BodyFatPage> createState() => _BodyFatPageState();
}

class _BodyFatPageState extends State<BodyFatPage> {
  double _bodyFat = 20;
  bool _isUnknown = false; // ตัวแปรเก็บสถานะว่าไม่ทราบค่าหรือไม่

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSubmitted(_bodyFat);
    });
  }

  IconData _getBodyIcon() {
    if (_bodyFat < 10) return Icons.accessibility_new;
    if (_bodyFat < 15) return Icons.directions_run;
    if (_bodyFat < 20) return Icons.person;
    if (_bodyFat < 25) return Icons.person_outline;
    if (_bodyFat < 30) return Icons.accessibility;
    return Icons.airline_seat_recline_extra;
  }

  Color _getBodyColor() {
    if (_bodyFat < 10) return const Color(0xFF00d2ff);
    if (_bodyFat < 15) return const Color(0xFF4A90E2);
    if (_bodyFat < 20) return const Color(0xFF6c5ce7);
    if (_bodyFat < 25) return const Color(0xFFffa502);
    if (_bodyFat < 30) return const Color(0xFFff6348);
    return const Color(0xFFe74c3c);
  }

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

              // ส่วนที่ให้ Fade และ Disable
              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _isUnknown ? 0.2 : 1.0, // จางลงเมื่อไม่ทราบค่า
                  child: IgnorePointer(
                    ignoring: _isUnknown, // ห้ามกด/เลื่อนเมื่อไม่ทราบค่า
                    child: Row(
                      children: [
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
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
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
                                SizedBox(
                                  height: 300,
                                  child: ListWheelScrollView.useDelegate(
                                    controller: FixedExtentScrollController(
                                      initialItem: 15,
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
                                    childDelegate:
                                        ListWheelChildBuilderDelegate(
                                          builder: (context, index) {
                                            if (index < 0 || index > 45)
                                              return null;
                                            final bodyFat = index + 5;
                                            final isSelected =
                                                bodyFat == _bodyFat.round();

                                            return Center(
                                              child: Text(
                                                '$bodyFat',
                                                style: TextStyle(
                                                  fontSize: isSelected
                                                      ? 48
                                                      : 28,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.white
                                                            .withOpacity(0.3),
                                                ),
                                              ),
                                            );
                                          },
                                          childCount: 46,
                                        ),
                                  ),
                                ),
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
                ),
              ),

              const SizedBox(height: 30),

              // ปุ่ม I don't know แบบ Holder
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isUnknown = !_isUnknown;
                      // ถ้า unknown ให้ส่ง 0.0 ถ้าไม่ unknown ให้ส่งค่าปัจจุบัน
                      widget.onSubmitted(_isUnknown ? 0.0 : _bodyFat);
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _isUnknown
                          ? Colors.blueAccent.withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isUnknown ? Colors.blueAccent : Colors.white24,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isUnknown ? Icons.check_circle : Icons.help_outline,
                          color: _isUnknown
                              ? Colors.blueAccent
                              : Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(width: 15),
                        Text(
                          "I don't know my fat%",
                          style: TextStyle(
                            color: _isUnknown ? Colors.white : Colors.white54,
                            fontWeight: _isUnknown
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
