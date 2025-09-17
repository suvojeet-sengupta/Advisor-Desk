import 'package:flutter/material.dart';

/// A widget that displays a shimmering skeleton loader.
///
/// This widget is used to indicate that content is loading. It can be
/// customized with different widths, heights, and shapes.
class SkeletonLoader extends StatefulWidget {
  /// The width of the skeleton loader.
  final double width;
  /// The height of the skeleton loader.
  final double height;
  /// The border radius of the skeleton loader.
  final BorderRadius borderRadius;
  /// The margin around the skeleton loader.
  final EdgeInsetsGeometry margin;
  /// Whether the skeleton loader should be a circle.
  final bool isCircle;

  /// Creates a skeleton loader.
  const SkeletonLoader({
    Key? key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.margin = EdgeInsets.zero,
    this.isCircle = false,
  }) : super(key: key);

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutSine,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Container(
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.isCircle ? null : widget.borderRadius,
        shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: widget.isCircle ? null : widget.borderRadius,
              shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
              gradient: LinearGradient(
                begin: Alignment(-1.0 + _animation.value, 0),
                end: Alignment(1.0 + _animation.value, 0),
                colors: [
                  baseColor,
                  highlightColor,
                  baseColor,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A skeleton loader in the shape of a card.
class SkeletonCard extends StatelessWidget {
  /// Creates a skeleton card.
  const SkeletonCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonLoader(
                width: 40,
                height: 40,
                isCircle: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonLoader(
                      height: 16,
                      width: 150,
                    ),
                    SizedBox(height: 8),
                    SkeletonLoader(
                      height: 14,
                      width: 100,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonLoader(height: 12),
          const SizedBox(height: 8),
          const SkeletonLoader(height: 12, width: 200),
        ],
      ),
    );
  }
}

/// A skeleton loader for the dashboard screen.
class DashboardSkeletonLoader extends StatelessWidget {
  /// Creates a dashboard skeleton loader.
  const DashboardSkeletonLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          const SkeletonLoader(
            height: 32,
            width: 200,
            margin: EdgeInsets.only(bottom: 8),
          ),
          const SkeletonLoader(
            height: 16,
            width: 150,
            margin: EdgeInsets.only(bottom: 24),
          ),
          // Grid skeleton
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SkeletonLoader(
                        width: 48,
                        height: 48,
                        isCircle: true,
                      ),
                      SizedBox(height: 12),
                      SkeletonLoader(
                        height: 14,
                        width: 80,
                      ),
                      SizedBox(height: 8),
                      SkeletonLoader(
                        height: 20,
                        width: 60,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
