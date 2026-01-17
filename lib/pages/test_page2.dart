import 'package:flutter/material.dart';

class TestPage2 extends StatefulWidget {
  const TestPage2({super.key});

  @override
  State<TestPage2> createState() => _TestPage2State();
}

// 1. เพิ่ม Mixin 'SingleTickerProviderStateMixin' เพื่อให้ class นี้เป็นตัวจับเวลา Animation ได้
class _TestPage2State extends State<TestPage2>
    with SingleTickerProviderStateMixin {
  // 2. ประกาศตัวแปรสำหรับควบคุม Animation
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    // 3. ตั้งค่า Controller: ให้ขยับขึ้นลงทุกๆ 2 วินาที และวนลูป (repeat reverse)
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // 4. กำหนดระยะทาง: ให้ขยับแกน Y ลงมานิดหน่อย (0.15 ของขนาดตัวมันเอง)
    // พร้อมใส่ Curve ให้การเคลื่อนไหวดูนุ่มนวล
    _animation = Tween<Offset>(begin: Offset.zero, end: const Offset(0, 0.15))
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut, // ใช้ easeInOut เพื่อให้หัวท้ายช้าๆ ดูลอยๆ
          ),
        );
  }

  @override
  void dispose() {
    // 5. *สำคัญมาก* ต้อง dispose controller ทิ้งเมื่อหน้านี้ถูกปิด เพื่อกัน Memory Leak
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Page2'),
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: const Color(0xFF5D4037),
      ),
      backgroundColor: const Color(0xFFFFFBF5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 6. ครอบ Icon ด้วย SlideTransition และใส่ animation ที่เราสร้างไว้
            SlideTransition(
              position: _animation,
              child: const Icon(
                Icons.science_rounded,
                size: 80,
                color: Color(0xFFFFC107),
              ),
            ),

            // เงาใต้ไอคอน (Optional: เพิ่มให้ดูสมจริงขึ้น เวลาไอคอนลอย เงาจะอยู่นิ่งๆ หรือทำ fade ได้)
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.all(Radius.elliptical(40, 10)),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Welcome to Test Page2',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'This page is inside Bottom Navigation',
              style: TextStyle(color: Color(0xFF8D6E63)),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                print("Button Pressed!");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5D4037),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Test Action'),
            ),
          ],
        ),
      ),
    );
  }
}
