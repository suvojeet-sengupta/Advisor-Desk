import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A custom refresh indicator that can display a Lottie animation.
class CustomRefreshIndicator extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;
  /// A function that's called when the user pulls down far enough to trigger a refresh.
  final Future<void> Function() onRefresh;
  /// The background color of the refresh indicator.
  final Color? backgroundColor;
  /// The path to a Lottie animation file to display during refresh.
  final String? lottieAsset;

  /// Creates a custom refresh indicator.
  const CustomRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.backgroundColor,
    this.lottieAsset,
  }) : super(key: key);

  @override
  State<CustomRefreshIndicator> createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  bool _isRefreshing = false;
  double _dragOffset = 0;
  final double _dragThreshold = 100;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Widget _buildLottieAnimation() {
    // Default loading animation if no asset provided
    if (widget.lottieAsset != null) {
      return Lottie.asset(
        widget.lottieAsset!,
        controller: _lottieController,
        height: 60,
        width: 60,
      );
    }
    
    // Fallback to built-in circular animation
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      child: Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        setState(() {
          _isRefreshing = true;
        });
        _scaleController.forward();
        _lottieController.repeat();
        
        await widget.onRefresh();
        
        _lottieController.stop();
        _scaleController.reverse();
        setState(() {
          _isRefreshing = false;
        });
      },
      backgroundColor: widget.backgroundColor ?? Theme.of(context).cardColor,
      color: Theme.of(context).colorScheme.primary,
      child: Stack(
        children: [
          widget.child,
          if (_isRefreshing)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 0,
              right: 0,
              child: Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildLottieAnimation(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A refresh indicator with a liquid-style wave animation.
class LiquidPullToRefresh extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;
  /// A function that's called when the user pulls down far enough to trigger a refresh.
  final Future<void> Function() onRefresh;
  /// The color of the wave.
  final Color? color;
  /// The background color of the refresh indicator.
  final Color? backgroundColor;

  /// Creates a liquid pull-to-refresh indicator.
  const LiquidPullToRefresh({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<LiquidPullToRefresh> createState() => _LiquidPullToRefreshState();
}

class _LiquidPullToRefreshState extends State<LiquidPullToRefresh>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _waveAnimation;
  bool _isRefreshing = false;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _waveAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final backgroundColor = widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is OverscrollNotification) {
          setState(() {
            _dragDistance = notification.overscroll.abs();
          });
        } else if (notification is ScrollEndNotification && _dragDistance > 100) {
          _refresh();
        } else if (notification is ScrollUpdateNotification) {
          if (_dragDistance > 0 && !_isRefreshing) {
            setState(() {
              _dragDistance = 0;
            });
          }
        }
        return false;
      },
      child: Stack(
        children: [
          widget.child,
          if (_dragDistance > 0 || _isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: _isRefreshing ? 80 : _dragDistance.clamp(0, 100),
                child: AnimatedBuilder(
                  animation: _waveAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: WavePainter(
                        color: color,
                        progress: _isRefreshing ? 1.0 : (_dragDistance / 100).clamp(0, 1),
                        wavePhase: _waveAnimation.value,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _isRefreshing = true;
    });
    _animationController.repeat();
    
    await widget.onRefresh();
    
    _animationController.stop();
    setState(() {
      _isRefreshing = false;
      _dragDistance = 0;
    });
  }
}

/// A custom painter that draws a wave.
class WavePainter extends CustomPainter {
  /// The color of the wave.
  final Color color;
  /// The progress of the wave animation.
  final double progress;
  /// The phase of the wave.
  final double wavePhase;

  /// Creates a wave painter.
  WavePainter({
    required this.color,
    required this.progress,
    required this.wavePhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3 + (0.7 * progress))
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 20 * progress;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final y = size.height - (size.height * progress) + 
                (waveHeight * sin((x / waveLength * 2 * 3.14159) + wavePhase));
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  /// A simple sine function approximation.
  double sin(double radians) {
    // Simple sine approximation
    final normalized = radians % (2 * 3.14159);
    if (normalized < 3.14159) {
      return normalized * (1 - normalized / 3.14159);
    } else {
      final adjusted = normalized - 3.14159;
      return -adjusted * (1 - adjusted / 3.14159);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.wavePhase != wavePhase;
  }
}
