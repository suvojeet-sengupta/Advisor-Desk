import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// A [ListView] that applies a staggered animation to its children.
///
/// This widget uses the `flutter_staggered_animations` package to animate
/// the list items as they appear.
class StaggeredListView extends StatelessWidget {
  /// The number of items in the list.
  final int itemCount;
  /// A builder function that returns a widget for each item.
  final Widget Function(BuildContext, int) itemBuilder;
  /// The vertical offset for the slide animation.
  final double? verticalOffset;
  /// The horizontal offset for the slide animation.
  final double? horizontalOffset;
  /// The duration of the animation.
  final Duration? duration;
  /// The physics of the scroll view.
  final ScrollPhysics? physics;
  /// The padding around the list.
  final EdgeInsetsGeometry? padding;

  /// Creates a staggered list view.
  const StaggeredListView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.verticalOffset,
    this.horizontalOffset,
    this.duration,
    this.physics,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: ListView.builder(
        physics: physics ?? const BouncingScrollPhysics(),
        padding: padding ?? const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (BuildContext context, int index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: duration ?? const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: verticalOffset ?? 50.0,
              horizontalOffset: horizontalOffset ?? 0.0,
              child: FadeInAnimation(
                child: itemBuilder(context, index),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A [GridView] that applies a staggered animation to its children.
///
/// This widget uses the `flutter_staggered_animations` package to animate
/// the grid items as they appear.
class StaggeredGridView extends StatelessWidget {
  /// The number of items in the grid.
  final int itemCount;
  /// A builder function that returns a widget for each item.
  final Widget Function(BuildContext, int) itemBuilder;
  /// The number of columns in the grid.
  final int crossAxisCount;
  /// The vertical offset for the slide animation.
  final double? verticalOffset;
  /// The horizontal offset for the slide animation.
  final double? horizontalOffset;
  /// The duration of the animation.
  final Duration? duration;
  /// The spacing between items in the main axis.
  final double mainAxisSpacing;
  /// The spacing between items in the cross axis.
  final double crossAxisSpacing;
  /// The aspect ratio of the children.
  final double childAspectRatio;
  /// The padding around the grid.
  final EdgeInsetsGeometry? padding;

  /// Creates a staggered grid view.
  const StaggeredGridView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    required this.crossAxisCount,
    this.verticalOffset,
    this.horizontalOffset,
    this.duration,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.childAspectRatio = 1.0,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: GridView.count(
        physics: const BouncingScrollPhysics(),
        padding: padding ?? const EdgeInsets.all(16),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
        children: List.generate(
          itemCount,
          (int index) {
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: duration ?? const Duration(milliseconds: 375),
              columnCount: crossAxisCount,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: itemBuilder(context, index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A widget that applies a fade, slide, and scale animation to its child.
///
/// This widget is used to animate a single list item.
class AnimatedListItem extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;
  /// The index of the item in the list, used for delaying the animation.
  final int index;
  /// The delay before the animation starts.
  final Duration? delay;

  /// Creates an animated list item.
  const AnimatedListItem({
    Key? key,
    required this.child,
    required this.index,
    this.delay,
  }) : super(key: key);

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
    ));

    // Start animation with delay based on index
    Future.delayed(
      widget.delay ?? Duration(milliseconds: widget.index * 100),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// A [Column] that applies a staggered animation to its children.
class StaggeredColumn extends StatelessWidget {
  /// The widgets below this widget in the tree.
  final List<Widget> children;
  /// How the children should be placed along the cross axis.
  final CrossAxisAlignment crossAxisAlignment;
  /// How the children should be placed along the main axis.
  final MainAxisAlignment mainAxisAlignment;
  /// The duration of the animation for each child.
  final Duration? animationDuration;
  /// The delay between the start of each child's animation.
  final Duration? delayBetweenItems;

  /// Creates a staggered column.
  const StaggeredColumn({
    Key? key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.animationDuration,
    this.delayBetweenItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: List.generate(children.length, (index) {
        return AnimatedListItem(
          index: index,
          delay: delayBetweenItems ?? Duration(milliseconds: index * 50),
          child: children[index],
        );
      }),
    );
  }
}
