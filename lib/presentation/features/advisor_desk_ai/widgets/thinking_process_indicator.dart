import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class ThinkingProcessIndicator extends StatefulWidget {
  final bool isThinking;
  final List<String> steps;

  const ThinkingProcessIndicator({
    Key? key,
    required this.isThinking,
    this.steps = const [],
  }) : super(key: key);

  @override
  State<ThinkingProcessIndicator> createState() => _ThinkingProcessIndicatorState();
}

class _ThinkingProcessIndicatorState extends State<ThinkingProcessIndicator> {
  bool _isExpanded = true; // Default to true to show the cool reasoning

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFinished = !widget.isThinking;
    final displaySteps = widget.steps.isEmpty && widget.isThinking 
        ? ["Processing..."] 
        : widget.steps;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Clickable)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                if (isFinished)
                   Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  )
                else
                  SpinPerfect(
                    infinite: true,
                    duration: const Duration(seconds: 2),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.psychology, color: theme.colorScheme.primary, size: 20),
                    ),
                  ),
                const SizedBox(width: 8),

                // Status Text
                Text(
                  isFinished ? "Thought Process" : (displaySteps.isNotEmpty ? displaySteps.last : "Thinking..."),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isFinished ? theme.colorScheme.onSurface.withOpacity(0.6) : theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(width: 4),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),

          // Expanded Details
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0, width: double.infinity),
            secondChild: Container(
              margin: const EdgeInsets.only(top: 8, left: 11), // Align with icon center roughly
              padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2), width: 1.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(displaySteps.length, (index) {
                  final isLast = index == displaySteps.length - 1 && !isFinished;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: FadeInLeft(
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLast ? Icons.radio_button_checked : Icons.check_circle,
                            size: 14,
                            color: isLast ? theme.colorScheme.primary : Colors.green.withOpacity(0.7),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            displaySteps[index],
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(isLast ? 0.9 : 0.5),
                              fontSize: 11,
                              fontWeight: isLast ? FontWeight.w500 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}