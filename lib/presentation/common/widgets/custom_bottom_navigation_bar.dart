import 'package:flutter/material.dart';

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

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          data: theme.copyWith(
            navigationBarTheme: theme.navigationBarTheme.copyWith(
              labelTextStyle: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
                }
                return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
              }),
            ),
          ),
          child: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: onTap,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            height: 60,
            indicatorColor: theme.colorScheme.primary.withOpacity(0.12),
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined, size: 22),
                selectedIcon: Icon(Icons.dashboard_rounded, size: 24, color: theme.colorScheme.primary),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_month_outlined, size: 22),
                selectedIcon: Icon(Icons.calendar_month_rounded, size: 24, color: theme.colorScheme.primary),
                label: 'Monthly',
              ),
              NavigationDestination(
                icon: const Icon(Icons.assessment_outlined, size: 22),
                selectedIcon: Icon(Icons.assessment_rounded, size: 24, color: theme.colorScheme.primary),
                label: 'Reports',
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined, size: 22),
                selectedIcon: Icon(Icons.settings_rounded, size: 24, color: theme.colorScheme.primary),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
  
