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
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height: 60,
          indicatorColor: theme.colorScheme.primary.withOpacity(0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, size: 22),
              selectedIcon: Icon(Icons.dashboard_rounded, size: 22),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined, size: 22),
              selectedIcon: Icon(Icons.calendar_month_rounded, size: 22),
              label: 'Monthly',
            ),
            NavigationDestination(
              icon: Icon(Icons.assessment_outlined, size: 22),
              selectedIcon: Icon(Icons.assessment_rounded, size: 22),
              label: 'Reports',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, size: 22),
              selectedIcon: Icon(Icons.settings_rounded, size: 22),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
  
