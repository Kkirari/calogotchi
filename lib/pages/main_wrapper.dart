import 'package:flutter/material.dart';
import 'package:Calogotchi/pages/test_page2.dart';
import 'display_page.dart';
import 'test_page.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text("Home Content")), // หน้า 0
    const DisplayPage(), // หน้า 1
    const TestPage(), // หน้า 2
    const TestPage2(), // หน้า 3
  ];

  // ฟังก์ชันสร้าง Card Button สำหรับใช้ใน Slider
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4E342E),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันเปิด Slider (Bottom Sheet)
  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // ทำให้พื้นหลังโปร่งใสเพื่อโชว์ Container มนๆ
      builder: (context) {
        return Container(
          width: double.infinity,
          height:
              MediaQuery.of(context).size.height *
              0.65, // ความสูงประมาณ 65% ของจอ
          decoration: const BoxDecoration(
            color: Color(0xFFF8F9FA), // สีเทาอ่อนให้ Card สีขาวเด่นขึ้น
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 15),
              // ขีดดึงด้านบน
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Choose Action",
                style: TextStyle(fontSize: 24, color: Color(0xFF4E342E)),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildMenuCard(
                      icon: Icons.camera_alt,
                      title: "Scan Meal",
                      color: Colors.redAccent,
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildMenuCard(
                      icon: Icons.search,
                      title: "Meal in Database",
                      color: Colors.blueAccent,
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildMenuCard(
                      icon: Icons.fitness_center,
                      title: "Add Activity",
                      color: Colors.orangeAccent,
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildMenuCard(
                      icon: Icons.edit_note,
                      title: "Custom Meal",
                      color: Colors.greenAccent,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),

      // ปุ่ม Floating ตรงกลางสีแดง
      floatingActionButton: Container(
        height: 70, // ขนาดใหญ่กว่าปกติ
        width: 70,
        child: FloatingActionButton(
          onPressed: () => _showActionSheet(context),
          backgroundColor: Colors.red,
          shape: const CircleBorder(),
          elevation: 6,
          child: const Icon(Icons.add, size: 40, color: Colors.white),
        ),
      ),

      // วางตำแหน่ง FAB ไว้ตรงกลาง Bottom Bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // แถบเมนูด้านล่าง
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // รอยเว้าตรงกลาง
        notchMargin: 10.0,
        color: const Color(0xFFFFFBF5),
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // เมนูฝั่งซ้าย
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.person, "Profile", 1),

              const SizedBox(width: 40), // ช่องว่างให้ปุ่ม FAB
              // เมนูฝั่งขวา
              _buildNavItem(Icons.science, "Test", 2),
              _buildNavItem(Icons.fitness_center, "Test2", 3),
            ],
          ),
        ),
      ),
    );
  }

  // Helper สร้างปุ่มกดของ Bottom Bar
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? const Color(0xFFFFC107)
                : const Color(0xFF8D6E63),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? const Color(0xFFFFC107)
                  : const Color(0xFF8D6E63),
            ),
          ),
        ],
      ),
    );
  }
}
