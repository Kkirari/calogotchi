import 'package:Calogotchi/services/meal_log.dart';
import 'package:Calogotchi/services/meal_log_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart'; // เพิ่มตัวนี้
import 'package:path/path.dart' as path; // เพิ่มตัวนี้

class CustomMeal extends StatefulWidget {
  const CustomMeal({super.key});

  @override
  State<CustomMeal> createState() => _CustomMealState();
}

class _CustomMealState extends State<CustomMeal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  // ฟังก์ชันเลือกรูปภาพ
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70, // ลดขนาดไฟล์เพื่อประหยัดพื้นที่
        maxWidth: 800, // จำกัดความกว้าง
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showSnackBar('Could not access $source', isError: true);
    }
  }

  // ฟังก์ชันบันทึกข้อมูล
  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      String? savedImagePath;

      // 🛑 ส่วนสำคัญ: บันทึกไฟล์รูปภาพลงในเครื่องแบบถาวร
      if (_selectedImage != null) {
        final directory = await getApplicationDocumentsDirectory();
        final String fileName =
            '${const Uuid().v4()}${path.extension(_selectedImage!.path)}';
        final File permanentImage = await _selectedImage!.copy(
          '${directory.path}/$fileName',
        );
        savedImagePath = permanentImage.path;
      }

      final mealLog = MealLog(
        id: const Uuid().v4(),
        date: DateTime.now(),
        name: _nameController.text.trim(),
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        fat: double.parse(_fatController.text),
        carbs: double.parse(_carbsController.text),
        imagePath: savedImagePath, // ใช้ path ที่บันทึกถาวรแล้ว
      );

      await MealLogService.addMeal(mealLog);

      if (!mounted) return;
      _showSnackBar('Delicious! Meal saved 🍛');

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar('Error saving: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF5D4037),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add Photo",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  Icons.camera_alt,
                  "Camera",
                  ImageSource.camera,
                ),
                _buildPickerOption(
                  Icons.photo_library,
                  "Gallery",
                  ImageSource.gallery,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(IconData icon, String label, ImageSource source) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
            _pickImage(source);
          },
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF5D4037), size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: const Text(
          'New Custom Meal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF5D4037),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // รูปภาพส่วนบน
              _ImageSection(
                selectedImage: _selectedImage,
                onTap: _showImagePickerOptions,
              ),
              const SizedBox(height: 40),
              _NameField(controller: _nameController),
              const SizedBox(height: 30),
              _NutritionGrid(
                caloriesController: _caloriesController,
                proteinController: _proteinController,
                fatController: _fatController,
                carbsController: _carbsController,
              ),
              const SizedBox(height: 40),
              _SaveButton(
                onPressed: _isSaving ? null : _saveMeal,
                isSaving: _isSaving,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ส่วนของ Widget ย่อย (ใช้ UI เดิมที่คุณทำไว้มาปรับแต่งเล็กน้อย) ---

class _ImageSection extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onTap;
  const _ImageSection({required this.selectedImage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                image: selectedImage != null
                    ? DecorationImage(
                        image: FileImage(selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: selectedImage == null
                  ? Icon(
                      Icons.add_a_photo_outlined,
                      size: 50,
                      color: Colors.grey[400],
                    )
                  : null,
            ),
            Positioned(
              bottom: 5,
              right: 5,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF5D4037),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  const _NameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: "Meal Name",
        hintText: "e.g. Salmon Salad",
        prefixIcon: const Icon(Icons.restaurant_menu),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (v) => v!.isEmpty ? "Please enter meal name" : null,
    );
  }
}

class _NutritionGrid extends StatelessWidget {
  final TextEditingController caloriesController,
      proteinController,
      fatController,
      carbsController;
  const _NutritionGrid({
    required this.caloriesController,
    required this.proteinController,
    required this.fatController,
    required this.carbsController,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildNutriInput(caloriesController, "Calories", "kcal", Colors.orange),
        _buildNutriInput(proteinController, "Protein", "g", Colors.red),
        _buildNutriInput(carbsController, "Carbs", "g", Colors.blue),
        _buildNutriInput(fatController, "Fat", "g", Colors.amber),
      ],
    );
  }

  Widget _buildNutriInput(
    TextEditingController ctrl,
    String label,
    String unit,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "0",
              suffixText: unit,
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isSaving;
  const _SaveButton({required this.onPressed, required this.isSaving});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5D4037),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
        ),
        child: isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "SAVE MEAL LOG",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
