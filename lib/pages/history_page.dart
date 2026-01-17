import 'package:Calogotchi/services/meal_log.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../services/meal_log_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Auto reload when page is opened
    MealLogService.refreshTrigger.addListener(_refreshMeals);
  }

  @override
  void dispose() {
    // ✅ เลิกฟัง: เพื่อคืน Memory
    MealLogService.refreshTrigger.removeListener(_refreshMeals);
    super.dispose();
  }

  Future<List<MealLog>> _loadMeals() {
    return MealLogService.getMealsByDate(_selectedDate);
  }

  void _refreshMeals() {
    if (mounted) {
      setState(() {});
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5D4037),
              onPrimary: Colors.white,
              onSurface: Color(0xFF5D4037),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) return 'Today';
    if (selectedDay == yesterday) return 'Yesterday';

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: const Text(
          'Meal History',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Color(0xFF5D4037),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF5D4037)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refreshMeals,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector
          _DateSelector(
            selectedDate: _selectedDate,
            onDateTap: _selectDate,
            formattedDate: _formatDate(_selectedDate),
          ),

          // Meals List
          Expanded(
            child: FutureBuilder<List<MealLog>>(
              key: ValueKey(_selectedDate), // Force rebuild when date changes
              future: _loadMeals(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF5D4037)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _EmptyState(date: _formatDate(_selectedDate));
                }

                final meals = snapshot.data!;
                final totalCalories = meals.fold(
                  0.0,
                  (sum, meal) => sum + meal.calories,
                );
                final totalProtein = meals.fold(
                  0.0,
                  (sum, meal) => sum + meal.protein,
                );
                final totalFat = meals.fold(0.0, (sum, meal) => sum + meal.fat);
                final totalCarbs = meals.fold(
                  0.0,
                  (sum, meal) => sum + meal.carbs,
                );

                return Column(
                  children: [
                    // Summary Card
                    _SummaryCard(
                      totalCalories: totalCalories,
                      totalProtein: totalProtein,
                      totalFat: totalFat,
                      totalCarbs: totalCarbs,
                      mealCount: meals.length,
                    ),

                    // Meals List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: meals.length,
                        itemBuilder: (context, index) {
                          return _MealCard(
                            meal: meals[index],
                            onRefresh: _refreshMeals,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGETS
// ============================================================================

class _DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onDateTap;
  final String formattedDate;

  const _DateSelector({
    required this.selectedDate,
    required this.onDateTap,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onDateTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('📅', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5D4037),
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double totalCalories;
  final double totalProtein;
  final double totalFat;
  final double totalCarbs;
  final int mealCount;

  const _SummaryCard({
    required this.totalCalories,
    required this.totalProtein,
    required this.totalFat,
    required this.totalCarbs,
    required this.mealCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D4C41), Color(0xFF5D4037)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D4037).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Today',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$mealCount ${mealCount == 1 ? 'meal' : 'meals'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              Text(
                totalCalories.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'kcal',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MacroChip(
                emoji: '💪',
                label: 'Protein',
                value: totalProtein.toStringAsFixed(0),
                unit: 'g',
              ),
              _MacroChip(
                emoji: '💧',
                label: 'Fat',
                value: totalFat.toStringAsFixed(0),
                unit: 'g',
              ),
              _MacroChip(
                emoji: '🍚',
                label: 'Carbs',
                value: totalCarbs.toStringAsFixed(0),
                unit: 'g',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final String unit;

  const _MacroChip({
    required this.emoji,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealLog meal;
  final VoidCallback onRefresh;

  const _MealCard({required this.meal, required this.onRefresh});

  String _getTimeFromDate(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Image Section
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(color: const Color(0xFFFFF9E6)),
              child:
                  meal.imagePath != null && File(meal.imagePath!).existsSync()
                  ? Image.file(File(meal.imagePath!), fit: BoxFit.cover)
                  : Center(
                      child: Text(
                        _getMealEmoji(meal.name),
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            meal.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D4037),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _getTimeFromDate(meal.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          '${meal.calories.toStringAsFixed(0)} kcal',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _MacroTag(
                          label: 'P',
                          value: meal.protein.toStringAsFixed(0),
                          color: const Color(0xFFEF5350),
                        ),
                        const SizedBox(width: 6),
                        _MacroTag(
                          label: 'F',
                          value: meal.fat.toStringAsFixed(0),
                          color: const Color(0xFFFF9800),
                        ),
                        const SizedBox(width: 6),
                        _MacroTag(
                          label: 'C',
                          value: meal.carbs.toStringAsFixed(0),
                          color: const Color(0xFF42A5F5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMealEmoji(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('chicken') || lowerName.contains('meat'))
      return '🍗';
    if (lowerName.contains('fish') || lowerName.contains('salmon')) return '🐟';
    if (lowerName.contains('salad') || lowerName.contains('vegetable'))
      return '🥗';
    if (lowerName.contains('rice') || lowerName.contains('fried rice'))
      return '🍚';
    if (lowerName.contains('pasta') || lowerName.contains('spaghetti'))
      return '🍝';
    if (lowerName.contains('burger') || lowerName.contains('sandwich'))
      return '🍔';
    if (lowerName.contains('pizza')) return '🍕';
    if (lowerName.contains('egg')) return '🥚';
    if (lowerName.contains('soup')) return '🍲';
    if (lowerName.contains('fruit')) return '🍎';
    return '🍽️';
  }
}

class _MacroTag extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroTag({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String date;

  const _EmptyState({required this.date});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          Text(
            'No meals logged',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'on $date',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
