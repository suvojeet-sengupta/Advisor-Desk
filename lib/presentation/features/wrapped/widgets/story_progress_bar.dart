import 'package:flutter/material.dart';

class StoryProgressBar extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final AnimationController animationController;

  const StoryProgressBar({
    Key? key,
    required this.currentIndex,
    required this.totalCount,
    required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalCount, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                double value = 0.0;
                if (index < currentIndex) {
                  value = 1.0;
                } else if (index == currentIndex) {
                  value = animationController.value;
                } else {
                  value = 0.0;
                }
                
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
