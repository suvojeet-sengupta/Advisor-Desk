import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/presentation/common/theme/theme_cubit.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';

/// A custom bottom navigation bar with a modern, rounded design.
///
/// This widget provides the main navigation for the application, with icons
/// that change based on the selected tab.
class CustomBottomNavigationBar extends StatelessWidget {
  /// The index of the currently active tab.
  final int currentIndex;
  /// A callback function that is called when a tab is tapped.
  final Function(int) onTap;

  /// Creates a custom bottom navigation bar.
  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
        final themeCubit = context.watch<ThemeCubit>();
    final isDarkMode = themeCubit.state.themeMode == AppThemeMode.dark ||
        (themeCubit.state.themeMode == AppThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Container(
      decoration: BoxDecoration(
        color: theme.bottomAppBarTheme.color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          showUnselectedLabels: false,
          showSelectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: [
            _buildNavItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard_rounded,
              label: 'Dashboard',
              index: 0,
            ),
            _buildNavItem(
              icon: Icons.calendar_month_outlined,
              activeIcon: Icons.calendar_month_rounded,
              label: 'Monthly',
              index: 1,
            ),
            _buildNavItem(
              icon: Icons.assessment_outlined,
              activeIcon: Icons.assessment_rounded,
              label: 'Reports',
              index: 2,
            ),
            _buildNavItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings_rounded,
              label: 'Settings',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a [BottomNavigationBarItem] with an inactive and active icon.
  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Icon(activeIcon),
      label: label,
    );
  }
}
