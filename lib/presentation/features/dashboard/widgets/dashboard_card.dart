import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';

class DashboardCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final double? progress; // Value between 0.0 and 1.0 (Point 4)
  final bool isLarge; // For Bento Grid (Point 1)

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.progress,
    this.isLarge = false,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return FadeInUp( // Point 3: Entry Animation
      duration: const Duration(milliseconds: 400),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          HapticFeedback.lightImpact(); // Point 3: Micro-interaction
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: EdgeInsets.all(widget.isLarge ? 24 : 16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: theme.cardTheme.shape is RoundedRectangleBorder 
                  ? (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius 
                  : BorderRadius.circular(28),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(widget.icon, color: widget.iconColor, size: widget.isLarge ? 28 : 22),
                    ),
                    if (widget.progress != null) // Point 4: In-Card Progress
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          value: widget.progress,
                          strokeWidth: 3.5,
                          backgroundColor: widget.iconColor.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(widget.iconColor),
                        ),
                      ),
                  ],
                ),
                if (widget.isLarge) const Spacer(),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.value,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: widget.isLarge ? 28 : 22,
                        color: theme.colorScheme.onSurface,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
