import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/physics.dart';

class CustomRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? backgroundColor;
  final String? lottieAsset;

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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _scaleController; 
  
  // Spring Physics for "Jumpback"
  final SpringDescription _spring = const SpringDescription(
    mass: 1,
    stiffness: 100, // Higher ease
    damping: 10,  // Lower damping = more bounciness
  );

  double _dragOffset = 0;
  bool _isRefreshing = false;
  static const double _refreshTriggerHeight = 100;
  static const double _maxDragOffset = 150;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    
    _controller.addListener(() {
      setState(() {
        _dragOffset = _controller.value * _refreshTriggerHeight;
      });
    });
    
    _scaleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    _scaleController.repeat(); // Spin indicator or pulse
    
    // Sync controller to current drag state to avoid visual jump
    _controller.value = _dragOffset / _refreshTriggerHeight;
    
    // Animate to hold position
    await _controller.animateTo(1.0, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
         setState(() => _isRefreshing = false);
         _scaleController.stop();
         
         // Smooth Jumpback Animation
         // Simulating spring release
         await _controller.animateWith(SpringSimulation(
             _spring, 
             _controller.value, 
             0.0, 
             -_controller.velocity,
         )); 
      }
    }
  }
  
  bool _handleScrollNotification(ScrollNotification notification) {
    if (_isRefreshing) return false;

    // Handle OverscrollNotification for Android (clamping scroll physics)
    if (notification is OverscrollNotification) {
      // Only track overscroll at the top (negative overscroll)
      if (notification.overscroll < 0) {
        setState(() {
          _dragOffset = (_dragOffset - notification.overscroll).clamp(0, _maxDragOffset);
        });
      }
    }

    // Handle ScrollUpdateNotification for iOS (bouncing scroll physics)
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.extentBefore == 0 && notification.metrics.pixels < 0) {
        final overscroll = notification.metrics.pixels.abs();
        setState(() {
          _dragOffset = overscroll.clamp(0, _maxDragOffset);
        });
      } else if (_dragOffset > 0 && notification.metrics.pixels >= 0 && !_isRefreshing) {
         // Reset offset when scrolling back down (not at top anymore)
         setState(() {
           _dragOffset = 0;
         });
      }
    }

    // Handle UserScrollNotification for finger lift detection
    if (notification is UserScrollNotification) {
      if (notification.direction == ScrollDirection.idle) {
        if (_dragOffset >= _refreshTriggerHeight) {
          _handleRefresh();
        } else if (_dragOffset > 0) {
          // Reset if released before trigger
          setState(() {
            _dragOffset = 0;
          });
        }
      }
    }
    
    // Handle ScrollEndNotification as fallback
    if (notification is ScrollEndNotification) {
       if (_dragOffset >= _refreshTriggerHeight) {
          _handleRefresh();
       } else if (_dragOffset > 0) {
          // Reset if released before trigger
          setState(() {
            _dragOffset = 0;
          });
       }
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Stack(
        children: [
          widget.child,
          
          // Indicator Overlay
          // Only visible when there is an offset or refreshing
          if (_dragOffset > 0 || _isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                height: _isRefreshing ? _refreshTriggerHeight : _dragOffset.clamp(0, _maxDragOffset),
                child: _buildLottieAnimation(),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildLottieAnimation() {
      if (widget.lottieAsset != null) {
        return Lottie.asset(
          widget.lottieAsset!,
          height: 50,
          width: 50,
        );
      }
      return Container(
        height: 45, width: 45,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0,4))
          ]
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
             value: _isRefreshing 
                ? null 
                : (_dragOffset / _refreshTriggerHeight).clamp(0.0, 1.0),
          ),
        ),
      );
  }
}

class LiquidPullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;

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

class WavePainter extends CustomPainter {
  final Color color;
  final double progress;
  final double wavePhase;

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
