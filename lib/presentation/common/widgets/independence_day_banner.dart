
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_svg/flutter_svg.dart';

class IndependenceDayBanner extends StatefulWidget {
  const IndependenceDayBanner({super.key});

  @override
  State<IndependenceDayBanner> createState() => _IndependenceDayBannerState();
}

class _IndependenceDayBannerState extends State<IndependenceDayBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isTodayAugust15th = false;

  @override
  void initState() {
    super.initState();
    _checkDate();
    if (_isTodayAugust15th) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      );
      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn),
      );
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, -0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller.forward();
    }
  }

  void _checkDate() {
    final now = DateTime.now();
    final formattedDate = DateFormat('d MMMM').format(now);
    if (formattedDate == '15 August') {
      setState(() {
        _isTodayAugust15th = true;
      });
    }
  }

  @override
  void dispose() {
    if (_isTodayAugust15th) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isTodayAugust15th) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            gradient: const LinearGradient(
              colors: [Colors.orange, Colors.white, Colors.green],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/images/indian_flag.svg',
                height: 40,
                width: 40,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Happy Independence Day!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
