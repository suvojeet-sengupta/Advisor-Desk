import 'package:flutter/material.dart';
import 'dart:math';

class WrappedBackground extends StatefulWidget {
  final int pageIndex;
  const WrappedBackground({Key? key, required this.pageIndex}) : super(key: key);

  @override
  State<WrappedBackground> createState() => _WrappedBackgroundState();
}

class _WrappedBackgroundState extends State<WrappedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _getGradientColors(int page) {
    switch (page) {
      case 0: return [const Color(0xFF2E0249), const Color(0xFF570A57)]; // Deep Purple
      case 1: return [const Color(0xFF0F3460), const Color(0xFF533483)]; // Blue/Indigo
      case 2: return [const Color(0xFFA91079), const Color(0xFF2E0249)]; // Pink/Purple
      case 3: return [const Color(0xFF006E7F), const Color(0xFFEE5007)]; // Teal/Orange
      case 4: return [const Color(0xFF166d3b), const Color(0xFF000000)]; // Green/Black
      case 5: return [const Color(0xFFF9D923), const Color(0xFF187498)]; // Gold/Blue
      default: return [const Color(0xFF000000), const Color(0xFF434343)]; // Black/Grey
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Gradient
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getGradientColors(widget.pageIndex),
            ),
          ),
        ),
        
        // Animated Blobs (Simple decorative circles)
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                Positioned(
                  top: -50 + (sin(_controller.value * 2 * pi) * 30),
                  left: -50 + (cos(_controller.value * 2 * pi) * 20),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100 + (cos(_controller.value * 2 * pi) * 40),
                  right: -30 + (sin(_controller.value * 2 * pi) * 20),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                 Positioned(
                  top: 300 + (sin(_controller.value * 2 * pi) * 50),
                  left: -20 + (cos(_controller.value * 2 * pi) * 30),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.03),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        
        // Noise Overlay (Optional - using a simple pattern if no asset)
        // Ignoring for now to keep it clean and performant without extra assets
      ],
    );
  }
}
