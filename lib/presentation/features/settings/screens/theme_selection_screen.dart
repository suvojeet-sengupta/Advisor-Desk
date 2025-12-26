import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:advisor_desk/core/constants/app_enums.dart';
import 'package:advisor_desk/presentation/common/theme/theme_cubit.dart';

import 'package:advisor_desk/presentation/common/widgets/custom_app_bar.dart';
import 'package:advisor_desk/presentation/common/widgets/custom_card.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Theme & Appearance'),
      body: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return SingleChildScrollView(
             padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context, 'Appearance Mode'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildThemeModeCard(context, 'Light', Icons.light_mode_rounded, AppThemeMode.light, themeState.themeMode)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildThemeModeCard(context, 'Dark', Icons.dark_mode_rounded, AppThemeMode.dark, themeState.themeMode)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildThemeModeCard(context, 'System', Icons.settings_brightness_rounded, AppThemeMode.system, themeState.themeMode)),
                  ],
                ),
                const SizedBox(height: 32),
                
                _buildSectionHeader(context, 'Accent Color'),
                const SizedBox(height: 12),
                CustomCard(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: AppColor.values.length,
                    itemBuilder: (context, index) {
                      final appColor = AppColor.values[index];
                      return _buildColorOption(context, appColor, themeState.color);
                    },
                  ),
                ),
                
                if (themeState.color == AppColor.materialYou)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      'Material You uses your system wallpaper colors for a personalized look (Android 12+).',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildThemeModeCard(BuildContext context, String title, IconData icon, AppThemeMode mode, AppThemeMode currentMode) {
    final isSelected = mode == currentMode;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => context.read<ThemeCubit>().setThemeMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
             if (!isSelected)
               BoxShadow(
                 color: Colors.black.withOpacity(0.05),
                 blurRadius: 10,
                 offset: const Offset(0, 4),
               ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? primaryColor : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, AppColor appColor, AppColor currentColor) {
    final isSelected = appColor == currentColor;
    final color = _getColorForEnum(appColor);

    return GestureDetector(
      onTap: () => context.read<ThemeCubit>().setColor(appColor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: isSelected 
              ? Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3) 
              : null,
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
        child: isSelected 
            ? Center(child: Icon(Icons.check, color: _getContrastingTextColor(color), size: 16))
            : null,
      ),
    );
  }
  
  Color _getContrastingTextColor(Color color) {
    // Simple logic to decide check icon color (white or black) based on luminance
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  

  Color _getColorForEnum(AppColor color) {
    switch (color) {
      case AppColor.materialYou:
        return Colors.blueGrey; // Placeholder color for the radio button circle
      case AppColor.orange:
        return Colors.orange;
      case AppColor.teal:
        return Colors.teal;
      case AppColor.pink:
        return Colors.pink;
      case AppColor.blue:
        return Colors.blue;
      case AppColor.green:
        return Colors.green;
      case AppColor.purple:
        return Colors.purple;
      case AppColor.red:
        return Colors.red;
    }
  }
}
