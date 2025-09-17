import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

/// A wrapper for the [Hero] widget that handles the `Material` ancestor requirement.
///
/// This widget simplifies the use of [Hero] animations by providing the necessary
/// `Material` widget with a transparent background.
class HeroWrapper extends StatelessWidget {
  /// The tag for the [Hero] widget.
  final String tag;
  /// The widget below this widget in the tree.
  final Widget child;
  /// The border radius to apply to the `ClipRRect` if provided.
  final BorderRadius? borderRadius;

  /// Creates a hero wrapper.
  const HeroWrapper({
    Key? key,
    required this.tag,
    required this.child,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        type: MaterialType.transparency,
        child: borderRadius != null
            ? ClipRRect(
                borderRadius: borderRadius!,
                child: child,
              )
            : child,
      ),
    );
  }
}

/// A card that animates on press and can be used with [Hero] animations.
class AnimatedDetailCard extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;
  /// The callback that is called when the card is tapped.
  final VoidCallback? onTap;
  /// The tag for the [Hero] animation. If null, no hero animation is used.
  final String? heroTag;
  /// The margin around the card.
  final EdgeInsetsGeometry? margin;
  /// The padding around the card's child.
  final EdgeInsetsGeometry? padding;
  /// The border radius of the card.
  final BorderRadius? borderRadius;
  /// The box shadow to apply to the card.
  final List<BoxShadow>? boxShadow;

  /// Creates an animated detail card.
  const AnimatedDetailCard({
    Key? key,
    required this.child,
    this.onTap,
    this.heroTag,
    this.margin,
    this.padding,
    this.borderRadius,
    this.boxShadow,
  }) : super(key: key);

  @override
  State<AnimatedDetailCard> createState() => _AnimatedDetailCardState();
}

class _AnimatedDetailCardState extends State<AnimatedDetailCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _elevationAnimation = Tween<double>(
      begin: 8.0,
      end: 4.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin,
            padding: widget.padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              boxShadow: widget.boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value / 2),
                    ),
                  ],
            ),
            child: widget.child,
          ),
        );
      },
    );

    if (widget.heroTag != null) {
      return GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _controller.reverse(),
        child: HeroWrapper(
          tag: widget.heroTag!,
          borderRadius: widget.borderRadius,
          child: content,
        ),
      );
    }

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: content,
    );
  }
}

/// A wrapper for the [OpenContainer] animation from the `animations` package.
///
/// This widget simplifies the creation of a container transform animation.
class OpenContainerWrapper extends StatelessWidget {
  /// The widget to display when the container is closed.
  final Widget closedWidget;
  /// The widget to display when the container is open.
  final Widget openWidget;
  /// The border radius of the closed container.
  final BorderRadius? closedBorderRadius;
  /// The color of the closed container.
  final Color? closedColor;
  /// The color of the open container.
  final Color? openColor;
  /// The elevation of the closed container.
  final double closedElevation;
  /// The elevation of the open container.
  final double openElevation;

  /// Creates an open container wrapper.
  const OpenContainerWrapper({
    Key? key,
    required this.closedWidget,
    required this.openWidget,
    this.closedBorderRadius,
    this.closedColor,
    this.openColor,
    this.closedElevation = 4,
    this.openElevation = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return OpenContainer(
      closedElevation: closedElevation,
      openElevation: openElevation,
      closedColor: closedColor ?? theme.cardColor,
      openColor: openColor ?? theme.scaffoldBackgroundColor,
      closedShape: RoundedRectangleBorder(
        borderRadius: closedBorderRadius ?? BorderRadius.circular(16),
      ),
      openShape: const RoundedRectangleBorder(),
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 500),
      closedBuilder: (context, openContainer) {
        return InkWell(
          onTap: openContainer,
          borderRadius: closedBorderRadius ?? BorderRadius.circular(16),
          child: closedWidget,
        );
      },
      openBuilder: (context, _) {
        return openWidget;
      },
    );
  }
}

/// A wrapper for the [SharedAxisTransition] animation.
class SharedAxisTransitionWrapper extends StatelessWidget {
  /// The widget below this widget in the tree.
  final Widget child;
  /// The type of transition to use.
  final SharedAxisTransitionType transitionType;
  /// Whether the transition should be reversed.
  final bool reverse;

  /// Creates a shared axis transition wrapper.
  const SharedAxisTransitionWrapper({
    Key? key,
    required this.child,
    this.transitionType = SharedAxisTransitionType.horizontal,
    this.reverse = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 300),
      reverse: reverse,
      transitionBuilder: (
        Widget child,
        Animation<double> primaryAnimation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          fillColor: Colors.transparent,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// A wrapper for the [FadeThroughTransition] animation.
class FadeThroughTransitionWrapper extends StatelessWidget {
  /// The widget below this widget in the tree.
  final Widget child;
  /// The duration of the transition.
  final Duration duration;

  /// Creates a fade through transition wrapper.
  const FadeThroughTransitionWrapper({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageTransitionSwitcher(
      duration: duration,
      transitionBuilder: (
        Widget child,
        Animation<double> primaryAnimation,
        Animation<double> secondaryAnimation,
      ) {
        return FadeThroughTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          fillColor: Colors.transparent,
          child: child,
        );
      },
      child: child,
    );
  }
}

/// A list tile that can be used with a [Hero] animation.
class AnimatedListTile extends StatelessWidget {
  /// A widget to display before the title.
  final Widget? leading;
  /// The primary content of the list tile.
  final Widget? title;
  /// Additional content displayed below the title.
  final Widget? subtitle;
  /// A widget to display after the title.
  final Widget? trailing;
  /// The callback that is called when the list tile is tapped.
  final VoidCallback? onTap;
  /// The tag for the [Hero] animation. If null, no hero animation is used.
  final String? heroTag;
  /// The padding for the list tile's content.
  final EdgeInsetsGeometry? contentPadding;

  /// Creates an animated list tile.
  const AnimatedListTile({
    Key? key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.heroTag,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tile = Material(
      color: Colors.transparent,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        contentPadding: contentPadding,
      ),
    );

    if (heroTag != null && leading != null) {
      return ListTile(
        leading: HeroWrapper(
          tag: heroTag!,
          child: leading!,
        ),
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        contentPadding: contentPadding,
      );
    }

    return tile;
  }
}
