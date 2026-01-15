import 'package:flutter/material.dart';

class WeightPage extends StatefulWidget {
  final Function(double) onSubmitted;
  const WeightPage({super.key, required this.onSubmitted});

  @override
  State<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  double _weight = 70;

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
                'Your Weight?',
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
                            initialItem: 40, // 70 - 30 = index 40
                          ),
                          itemExtent: 80,
                          perspective: 0.003,
                          diameterRatio: 1.5,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _weight = (index + 30).toDouble();
                              widget.onSubmitted(_weight);
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              if (index < 0 || index > 170) return null;
                              final weight = index + 30;
                              final isSelected = weight == _weight.round();

                              return Center(
                                child: Text(
                                  '$weight',
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
                            childCount: 171, // 30-200 kg
                          ),
                        ),
                      ),
                      // Label "kg"
                      Positioned(
                        right: 40,
                        child: Text(
                          'kg',
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
