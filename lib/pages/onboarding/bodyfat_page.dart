import 'package:flutter/material.dart';

class BodyFatPage extends StatefulWidget {
  final Function(double) onSubmitted;
  const BodyFatPage({super.key, required this.onSubmitted});

  @override
  State<BodyFatPage> createState() => _BodyFatPageState();
}

class _BodyFatPageState extends State<BodyFatPage> {
  double _bodyFat = 20;
  bool _isUnknown = false;

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
    return const Color(0xFFFFC107); // ✅ accent เหลืองสด
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
      backgroundColor: const Color(0xFFFFFBF5), // ✅ พื้นหลังขาวนวล
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
                  color: Color(0xFF8D6E63), // ✅ น้ำตาลอ่อน
                ),
              ),
              const Text(
                'Percentage',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037), // ✅ น้ำตาลเข้ม
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Optional',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9E9E9E), // ✅ เทาอ่อน
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 40),

              Expanded(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: _isUnknown ? 0.2 : 1.0,
                  child: IgnorePointer(
                    ignoring: _isUnknown,
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
                                                      ? const Color(
                                                          0xFF5D4037,
                                                        ) // ✅ น้ำตาลเข้ม
                                                      : const Color(
                                                          0xFF9E9E9E,
                                                        ), // ✅ เทาอ่อน
                                                ),
                                              ),
                                            );
                                          },
                                          childCount: 46,
                                        ),
                                  ),
                                ),
                                const Positioned(
                                  right: 10,
                                  child: Text(
                                    '%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF9E9E9E), // ✅ เทาอ่อน
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

              const SizedBox(height: 20),

              // ปุ่ม I don't know แบบ Holder
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isUnknown = !_isUnknown;
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
                          ? const Color(0xFFFFC107).withOpacity(0.2)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isUnknown
                            ? const Color(0xFFFFC107)
                            : Colors.white24,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isUnknown ? Icons.check_circle : Icons.help_outline,
                          color: _isUnknown
                              ? const Color(0xFF5D4037)
                              : const Color(0xFF9E9E9E),
                          size: 20,
                        ),
                        const SizedBox(width: 15),
                        Text(
                          "I don't know my fat%",
                          style: TextStyle(
                            color: _isUnknown
                                ? const Color(0xFF5D4037)
                                : const Color(0xFF9E9E9E),
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
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
