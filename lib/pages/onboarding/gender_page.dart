import 'package:flutter/material.dart';

class GenderPage extends StatefulWidget {
  final Function(String) onSelected;
  const GenderPage({super.key, required this.onSelected});

  @override
  State<GenderPage> createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  String? selectedGender;

  void _selectGender(String gender) {
    setState(() {
      selectedGender = gender;
    });
    widget.onSelected(gender);
    print("LOG: Gender selected = $gender");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFFFBF5,
      ), // ✅ พื้นหลังขาวนวลเหมือน GoalPage
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Welcome to Calogotchi',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF8D6E63), // ✅ น้ำตาลอ่อน
                ),
              ),
              const Text(
                'Select Gender',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037), // ✅ น้ำตาลเข้ม
                ),
              ),
              const SizedBox(height: 60),
              Expanded(
                child: Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: _GenderCard(
                          icon: Icons.male,
                          label: 'Male',
                          isSelected: selectedGender == 'Male',
                          selectedColor: const Color(0xFF4A90E2), // ✅ เหลืองทอง
                          onTap: () => _selectGender('Male'),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _GenderCard(
                          icon: Icons.female,
                          label: 'Female',
                          isSelected: selectedGender == 'Female',
                          selectedColor: const Color(
                            0xFFE91E63,
                          ), // ✅ เหลืองอ่อน
                          onTap: () => _selectGender('Female'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _GenderCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 180,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedColor : const Color(0xFFE0E0E0),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? selectedColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: isSelected ? selectedColor : const Color(0xFF757575),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color(0xFF5D4037) // น้ำตาลเข้ม
                    : const Color(0xFF757575), // เทา
              ),
            ),
          ],
        ),
      ),
    );
  }
}
