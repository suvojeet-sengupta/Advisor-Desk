import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class ThinkingProcessIndicator extends StatefulWidget {
  final bool isThinking;

  const ThinkingProcessIndicator({Key? key, required this.isThinking}) : super(key: key);

  @override
  State<ThinkingProcessIndicator> createState() => _ThinkingProcessIndicatorState();
}

class _ThinkingProcessIndicatorState extends State<ThinkingProcessIndicator> {
  bool _isExpanded = false;
  int _currentStep = 0;
  Timer? _timer;

  final List<String> _steps = [
    "Analyzing your query...",
    "Fetching context...",
    "Processing data...",
    "Generating response...",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isThinking) {
      _startStepSimulation();
    }
  }

  @override
  void didUpdateWidget(ThinkingProcessIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isThinking && !oldWidget.isThinking) {
      _currentStep = 0;
      _startStepSimulation();
    } else if (!widget.isThinking) {
      _stopStepSimulation();
    }
  }

  @override
  void dispose() {
    _stopStepSimulation();
    super.dispose();
  }

  void _startStepSimulation() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (mounted) {
        setState(() {
          if (_currentStep < _steps.length - 1) {
            _currentStep++;
          } else {
            // Loop the last step or just stay there
            // timer.cancel(); 
          }
        });
      }
    });
  }

  void _stopStepSimulation() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isThinking) return const SizedBox.shrink();

    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 16.0),
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
                // Animated Brain/Sparkle Icon
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
                const SizedBox(width: 12),
                
                // Status Text
                Text(
                  _steps[_currentStep],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                const SizedBox(width: 8),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
          ),

          // Expanded Details
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0, width: double.infinity),
            secondChild: Container(
              margin: const EdgeInsets.only(top: 12, left: 18),
              padding: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2), width: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(_steps.length, (index) {
                  final isCompleted = index < _currentStep;
                  final isCurrent = index == _currentStep;
                  final isFuture = index > _currentStep;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted ? Icons.check_circle_rounded : (isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                          size: 16,
                          color: isFuture 
                              ? theme.disabledColor 
                              : (isCurrent ? theme.colorScheme.primary : Colors.green),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _steps[index],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isFuture 
                                ? theme.disabledColor 
                                : theme.colorScheme.onSurface.withOpacity(0.8),
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
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
