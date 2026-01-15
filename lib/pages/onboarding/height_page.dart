import 'package:flutter/material.dart';

class HeightPage extends StatefulWidget {
  final Function(double) onSubmitted;
  const HeightPage({super.key, required this.onSubmitted});

  @override
  State<HeightPage> createState() => _HeightPageState();
}

class _HeightPageState extends State<HeightPage> {
  double _height = 170;

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
                'What is',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                ),
              ),
              const Text(
                'Your Height?',
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
                        width: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6c5ce7).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
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
                            initialItem: 70, // 170 - 100 = index 70
                          ),
                          itemExtent: 80,
                          perspective: 0.003,
                          diameterRatio: 1.5,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _height = (index + 100).toDouble();
                              widget.onSubmitted(_height);
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              if (index < 0 || index > 150) return null;
                              final height = index + 100;
                              final isSelected = height == _height.round();

                              return Center(
                                child: Text(
                                  '$height',
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
                            childCount: 151, // 100-250 cm
                          ),
                        ),
                      ),
                      // Label "cm"
                      Positioned(
                        right: 40,
                        child: Text(
                          'cm',
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
