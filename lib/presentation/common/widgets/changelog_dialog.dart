import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/animated_button.dart';
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(isDark ? 0.85 : 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.onSurface.withOpacity(0.1),
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
                        const Color(0xFF1E3C72),
                        const Color(0xFF2A5298),
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
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "What's New",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "v1.5.0 • AI Update",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(context, "🤖 Next-Gen AI"),
                        _buildFeatureItem(
                          context,
                          title: "Powered by Gemini",
                          description: "Experience the power of Google's Gemini AI for deep insights, smarter goal suggestions, and date-specific queries.",
                          icon: Icons.auto_awesome,
                          color: Colors.blue,
                        ),
                        _buildFeatureItem(
                          context,
                          title: "Context-Aware Chat",
                          description: "The AI now understands your 12-month history, handles hypothetical scenarios, and remembers previous conversations.",
                          icon: Icons.psychology_outlined,
                          color: Colors.teal,
                        ),
                        _buildFeatureItem(
                          context,
                          title: "Smart Interactions",
                          description: "Features typing indicators to feel more alive, plus new options to manage or delete chat history.",
                          icon: Icons.chat_bubble_outline_rounded,
                          color: Colors.indigo,
                        ),

                        const SizedBox(height: 24),
                        _buildSectionHeader(context, "🎨 Visual Overhaul"),
                        _buildFeatureItem(
                          context,
                          title: "Stunning Dashboard",
                          description: "A complete redesign inspired by top-tier apps, featuring pulse animations and professional layouts.",
                          icon: Icons.dashboard_customize_outlined,
                          color: Colors.deepOrange,
                        ),
                        _buildFeatureItem(
                          context,
                          title: "Premium Screens",
                          description: "Salary, Reports, Credits, and Settings screens have been upgraded with glassy gradients and a premium feel.",
                          icon: Icons.brush_outlined,
                          color: Colors.purple,
                        ),
                        
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Did you know? You can now ask the AI who created it! Try it out.",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer Action
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    backgroundColor: const Color(0xFF1E3C72),
                    foregroundColor: Colors.white,
                    width: double.infinity,
                    child: const Text(
                      "Awesome, Let's Go!",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
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
  }) {
    final theme = Theme.of(context);
    return Padding(
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}