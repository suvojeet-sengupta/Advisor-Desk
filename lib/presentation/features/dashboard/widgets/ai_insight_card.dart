import 'package:advisor_desk/domain/entities/ai_insight.dart';
import 'package:flutter/material.dart';
import 'package:advisor_desk/presentation/common/widgets/animated_button.dart';

class AiInsightCard extends StatelessWidget {
  final AiInsight insight;
  final VoidCallback? onActionPressed;
  final VoidCallback? onTap;

  const AiInsightCard({
    Key? key,
    required this.insight,
    this.onActionPressed,
    this.onTap,
  }) : super(key: key);

  void _showAiInsightInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About Advisor Desk AI Insight'),
          content: const Text(
            'Advisor Desk AI is your personal performance assistant. It analyzes your daily performance, goals, and other metrics to provide you with personalized insights and suggestions. The goal is to help you improve your performance, achieve your targets, and make your work life easier.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    
    // Generate a rich gradient based on the primary color
    // We use HSL to ensure we get a nice visible gradient regardless of the input color
    final hslPrimary = HSLColor.fromColor(primaryColor);
    final color1 = hslPrimary.withLightness((hslPrimary.lightness + 0.1).clamp(0.0, 1.0)).toColor();
    final color2 = hslPrimary.withLightness((hslPrimary.lightness - 0.2).clamp(0.0, 1.0)).withSaturation((hslPrimary.saturation + 0.1).clamp(0.0, 1.0)).toColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFFFD700),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Advisor Desk AI',
                          style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    IconButton(
                        icon: Icon(Icons.info_outline_rounded, color: Colors.white.withOpacity(0.7), size: 22),
                        onPressed: () => _showAiInsightInfoDialog(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  insight.message,
                  style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        height: 1.4,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (insight.buttonText != null) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: _PulseAnimation(
                      child: AnimatedButton(
                        onPressed: onActionPressed,
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          insight.buttonText!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseAnimation extends StatefulWidget {
  final Widget child;
  const _PulseAnimation({required this.child});

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}
