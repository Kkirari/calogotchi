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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSubmitted(_age.round());
      print("LOG: Default age submitted = ${_age.round()}");
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
                'How Old',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF8D6E63), // ✅ น้ำตาลอ่อน
                ),
              ),
              const Text(
                'Are You?',
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
                      Container(
                        height: 80,
                        width: 150,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFFFC107,
                          ).withOpacity(0.2), // ✅ accent เหลือง
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: const Color(0xFFFFC107), // ✅ accent เหลืองสด
                            width: 2,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 300,
                        child: ListWheelScrollView.useDelegate(
                          controller: FixedExtentScrollController(
                            initialItem: 20,
                          ),
                          itemExtent: 80,
                          perspective: 0.003,
                          diameterRatio: 1.5,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _age = (index + 10).toDouble();
                              final selectedAge = _age.round();
                              widget.onSubmitted(selectedAge);
                              print("LOG: Age selected = $selectedAge");
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
                                        ? const Color(
                                            0xFF5D4037,
                                          ) // ✅ น้ำตาลเข้ม
                                        : const Color(0xFF9E9E9E), // ✅ เทาอ่อน
                                  ),
                                ),
                              );
                            },
                            childCount: 91,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 30,
                        child: Text(
                          'Years old',
                          style: const TextStyle(
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
