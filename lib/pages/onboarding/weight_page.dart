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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSubmitted(_weight);
      print("LOG: Default weight submitted = $_weight");
    });
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
                'What is',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF8D6E63), // ✅ น้ำตาลอ่อน
                ),
              ),
              const Text(
                'Your Weight?',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037), // ✅ น้ำตาลเข้ม
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
                          color: const Color(
                            0xFFFFC107,
                          ).withOpacity(0.2), // ✅ accent เหลือง
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFFFC107), // ✅ accent เหลืองสด
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
                              print("LOG: Weight selected = $_weight");
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
                                        ? const Color(
                                            0xFF5D4037,
                                          ) // ✅ น้ำตาลเข้ม
                                        : const Color(0xFF9E9E9E), // ✅ เทาอ่อน
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
                        child: const Text(
                          'kg',
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
    );
  }
}
