import 'package:flutter/material.dart';

/// Represents a single step in an interactive tutorial.
///
/// This class defines the target widget to be highlighted, the text to be
/// displayed, and other properties for a single step in the tutorial.
class TutorialStep {
  /// A [GlobalKey] that identifies the widget to be highlighted.
  final GlobalKey targetKey;
  /// The tutorial text to be displayed for this step.
  final String text;
  /// The alignment of the tutorial text relative to the highlighted widget.
  final AlignmentGeometry textAlignment;
  /// The padding around the tutorial text.
  final EdgeInsetsGeometry textPadding;
  /// Whether to show a swipe animation hint.
  final bool showSwipeHint;

  /// Creates a tutorial step.
  TutorialStep({
    required this.targetKey,
    required this.text,
    this.textAlignment = Alignment.bottomCenter,
    this.textPadding = const EdgeInsets.all(16.0),
    this.showSwipeHint = false,
  });
}

/// An overlay widget that displays an interactive tutorial.
///
/// This widget takes a list of [TutorialStep]s and displays them one by one,
/// highlighting the target widget for each step.
class InteractiveTutorialOverlay extends StatefulWidget {
  /// The list of steps in the tutorial.
  final List<TutorialStep> steps;
  /// A callback function that is called when the tutorial is finished.
  final VoidCallback onFinish;

  /// Creates an interactive tutorial overlay.
  const InteractiveTutorialOverlay({
    Key? key,
    required this.steps,
    required this.onFinish,
  }) : super(key: key);

  @override
  _InteractiveTutorialOverlayState createState() => _InteractiveTutorialOverlayState();
}

class _InteractiveTutorialOverlayState extends State<InteractiveTutorialOverlay> with SingleTickerProviderStateMixin {
  int _currentStepIndex = 0;
  late AnimationController _swipeAnimationController;
  late Animation<Offset> _swipeAnimation;

  @override
  void initState() {
    super.initState();
    _swipeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.5, 0.0), // Swipe left
    ).animate(CurvedAnimation(
      parent: _swipeAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _swipeAnimationController.dispose();
    super.dispose();
  }

  TutorialStep get _currentStep => widget.steps[_currentStepIndex];

  void _nextStep() {
    setState(() {
      if (_currentStepIndex < widget.steps.length - 1) {
        _currentStepIndex++;
      } else {
        widget.onFinish();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final RenderBox? targetBox = _currentStep.targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (targetBox == null) {
      // If target widget is not rendered yet, or key is invalid, just show a dim overlay
      return GestureDetector(
        onTap: _nextStep,
        child: Container(
          color: Colors.black54,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(), // Or some other loading indicator
        ),
      );
    }

    final targetRect = targetBox.localToGlobal(Offset.zero) & targetBox.size;

    return Stack(
      children: [
        // Dim background
        GestureDetector(
          onTap: _nextStep,
          child: Container(
            color: Colors.black54,
          ),
        ),

        // Highlighted area (cutout)
        Positioned.fromRect(
          rect: targetRect,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1), // Slightly visible highlight
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ),

        // Tutorial Text
        Positioned.fill(
          child: Align(
            alignment: _currentStep.textAlignment,
            child: Padding(
              padding: _currentStep.textPadding,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentStep.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_currentStep.showSwipeHint)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: SlideTransition(
                          position: _swipeAnimation,
                          child: const Icon(
                            Icons.swipe_left,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _nextStep,
                      child: Text(_currentStepIndex == widget.steps.length - 1 ? 'Got It!' : 'Next'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
