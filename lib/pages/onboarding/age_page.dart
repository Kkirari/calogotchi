import 'package:flutter/material.dart';

class AgePage extends StatefulWidget {
  final Function(int) onSubmitted;
  const AgePage({super.key, required this.onSubmitted});

  @override
  State<AgePage> createState() => _AgePageState();
}

class _AgePageState extends State<AgePage> {
  double _age = 30;

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
                'How Old',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                ),
              ),
              const Text(
                'Are You?',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 60),
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Highlight box ตรงกลาง
                      Container(
                        height: 80,
                        width: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6c5ce7).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: const Color(0xFF6c5ce7),
                            width: 2,
                          ),
                        ),
                      ),
                      // Wheel picker
                      SizedBox(
                        height: 300,
                        child: ListWheelScrollView.useDelegate(
                          controller: FixedExtentScrollController(
                            initialItem: 20, // 30 - 10 = index 20
                          ),
                          itemExtent: 80,
                          perspective: 0.003,
                          diameterRatio: 1.5,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _age = (index + 10).toDouble();
                              widget.onSubmitted(_age.round());
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              if (index < 0 || index > 90) return null;
                              final age = index + 10;
                              final isSelected = age == _age.round();

                              return Center(
                                child: Text(
                                  '$age',
                                  style: TextStyle(
                                    fontSize: isSelected ? 56 : 32,
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
                            childCount: 91, // 10-100
                          ),
                        ),
                      ),
                      // Label "years old"
                      Positioned(
                        right: 30,
                        child: Text(
                          'Years old',
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
    );
  }
}
