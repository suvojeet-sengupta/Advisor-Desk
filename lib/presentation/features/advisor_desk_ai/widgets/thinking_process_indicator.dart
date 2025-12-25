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
    } else {
      _currentStep = _steps.length; // All done
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
      _currentStep = _steps.length;
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
    final theme = Theme.of(context);
    final isFinished = !widget.isThinking;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
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
                  isFinished ? "Thought Process" : _steps[(_currentStep < _steps.length) ? _currentStep : _steps.length - 1],
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
              padding: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2), width: 1.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(_steps.length, (index) {
                  final isCompleted = isFinished || index < _currentStep;
                  final isCurrent = !isFinished && index == _currentStep;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCompleted ? Icons.check : (isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                          size: 12,
                          color: isCompleted ? Colors.green : (isCurrent ? theme.colorScheme.primary : theme.disabledColor),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _steps[index],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(isCompleted || isCurrent ? 0.8 : 0.4),
                            fontSize: 10,
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