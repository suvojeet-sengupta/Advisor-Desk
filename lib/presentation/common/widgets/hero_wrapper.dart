import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class HeroWrapper extends StatelessWidget {
  final String tag;
  final Widget child;
  final BorderRadius? borderRadius;

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

class AnimatedDetailCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? heroTag;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

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

class OpenContainerWrapper extends StatelessWidget {
  final Widget closedWidget;
  final Widget openWidget;
  final BorderRadius? closedBorderRadius;
  final Color? closedColor;
  final Color? openColor;
  final double closedElevation;
  final double openElevation;

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

class SharedAxisTransitionWrapper extends StatelessWidget {
  final Widget child;
  final SharedAxisTransitionType transitionType;
  final bool reverse;

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

class FadeThroughTransitionWrapper extends StatelessWidget {
  final Widget child;
  final Duration duration;

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

class AnimatedListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? heroTag;
  final EdgeInsetsGeometry? contentPadding;

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
