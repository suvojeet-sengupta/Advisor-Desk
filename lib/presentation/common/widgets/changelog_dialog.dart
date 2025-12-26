import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/animated_button.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:ui';

class ChangelogDialog extends StatelessWidget {
  const ChangelogDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 650),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(isDark ? 0.90 : 0.98),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Gradient
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: BounceInDown(
                        from: 10,
                        child: Icon(Icons.celebration_rounded, color: theme.colorScheme.onPrimary, size: 24)
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "What's New",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "v1.7.0 • Desi AI & Better Stories",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Flexible(
                child: RepaintBoundary(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, "🌟 Top Updates", delay: 50),
                        _buildFeatureItem(
                          context,
                          title: "Full Hinglish Dashboard",
                          description: "The app now speaks your language! Desi Hinglish support added across the entire dashboard and settings for a more personal touch.",
                          icon: Icons.translate_rounded,
                          color: Colors.orange,
                          delay: 100,
                        ),
                        _buildFeatureItem(
                          context,
                          title: "AI Voice & Thinking",
                          description: "Talk to Advisor Desk AI with the new Voice Mode! Plus, see the AI's 'Thinking Process' in real-time with the new live indicator.",
                          icon: Icons.psychology_alt_rounded,
                          color: Colors.purple,
                          delay: 150,
                        ),
                        
                        const SizedBox(height: 24),
                        _buildSectionHeader(context, "🎥 Wrapped Improvements", delay: 200),
                        _buildFeatureItem(
                          context,
                          title: "Instagram-Style Stories",
                          description: "Advisor Wrapped now features smooth auto-advance and Instagram-style story progress bars for a premium viewing experience.",
                          icon: Icons.auto_stories_rounded,
                          color: Colors.pinkAccent,
                          delay: 250,
                        ),
                        _buildFeatureItem(
                          context,
                          title: "Monthly Auto-Popup",
                          description: "Never miss your performance recap! Advisor Wrapped will now automatically show up on the 1st of every month.",
                          icon: Icons.calendar_month_rounded,
                          color: Colors.blue,
                          delay: 300,
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader(context, "🚀 System & Performance", delay: 350),
                        _buildFeatureItem(
                          context,
                          title: "Android 14 Ready",
                          description: "Added support for Predictive Back gestures, Edge-to-Edge UI, and the latest Splash Screen API for a modern feel.",
                          icon: Icons.android_rounded,
                          color: Colors.green,
                          delay: 400,
                        ),

                        const SizedBox(height: 16),
                        ZoomIn(
                          delay: const Duration(milliseconds: 450),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.secondary.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.tips_and_updates_rounded, color: theme.colorScheme.secondary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Pro Tip: You can now delete individual AI chats to keep your history clean!",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer Action
              Padding(
                padding: const EdgeInsets.all(24),
                child: FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: AnimatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    width: double.infinity,
                    child: Text(
                      "Explore Now",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {int delay = 0}) {
    return FadeInLeft(
      delay: Duration(milliseconds: delay),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    int delay = 0,
  }) {
    final theme = Theme.of(context);
    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
