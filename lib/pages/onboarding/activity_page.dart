import 'package:flutter/material.dart';

class ActivityPage extends StatefulWidget {
  final Function(String) onSelected;
  const ActivityPage({super.key, required this.onSelected});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String? selectedActivity;

  final List<Map<String, dynamic>> activities = [
    {
      'label': 'Sedentary',
      'subtitle': 'Office job',
      'level': '',
      'icon': Icons.chair_outlined,
      'value': 'Sedentary (office job)',
    },
    {
      'label': 'Lightly Active',
      'subtitle': 'Light exercise',
      'level': '(1-2 days/week)',
      'icon': Icons.directions_walk,
      'value': 'Lightly Active',
    },
    {
      'label': 'Moderately Active',
      'subtitle': 'Moderate exercise',
      'level': '(3-5 days/week)',
      'icon': Icons.directions_run,
      'value': 'Moderately Active',
    },
    {
      'label': 'Very Active',
      'subtitle': 'Intense exercise',
      'level': '(6-7 days/week)',
      'icon': Icons.fitness_center,
      'value': 'Very Active',
    },
  ];

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
                'Your Activity',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                ),
              ),
              const Text(
                'Level',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 60),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    final isSelected = selectedActivity == activity['value'];

                    return _ActivityCard(
                      icon: activity['icon'],
                      label: activity['label'],
                      subtitle: activity['subtitle'],
                      level: activity['level'],
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          selectedActivity = activity['value'];
                          widget.onSelected(activity['value']);
                          print(
                            "LOG: Activity selected = ${activity['value']}",
                          );
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String level;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.icon,
    required this.label,
    required this.level,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6c5ce7) : const Color(0xFF16213e),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6c5ce7)
                : Colors.white.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 56,
                color: isSelected ? Colors.white : Colors.white54,
              ),
              const SizedBox(height: 16),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : Colors.white.withOpacity(0.5),
                ),
              ),
              Text(
                level,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
