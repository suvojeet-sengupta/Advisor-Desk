import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color? backgroundColor;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final List<Map<String, dynamic>> items = [
      {'icon': Icons.dashboard_rounded, 'label': 'Home'},
      {'icon': Icons.calendar_month_rounded, 'label': 'Logs'},
      {'icon': Icons.assessment_rounded, 'label': 'Reports'},
      {'icon': Icons.settings_rounded, 'label': 'Settings'},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: backgroundColor ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap(index);
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'],
                          color: isSelected 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                          size: isSelected ? 26 : 24,
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isSelected ? 4 : 0,
                          height: isSelected ? 4 : 0,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (isSelected)
                          Text(
                            item['label'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
  
