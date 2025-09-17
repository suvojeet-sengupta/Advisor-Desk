import 'package:flutter/material.dart';

/// A custom app bar widget with a consistent style.
///
/// This widget provides a standardized app bar for the application, with
/// options for a title, actions, a leading widget, and a bottom widget.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title of the app bar. Either [title] or [titleWidget] must be provided.
  final String? title;
  /// A widget to use as the title of the app bar.
  final Widget? titleWidget;
  /// A list of widgets to display after the title.
  final List<Widget>? actions;
  /// A widget to display before the title.
  final Widget? leading;
  /// A widget to display at the bottom of the app bar.
  final PreferredSizeWidget? bottom;

  /// Creates a custom app bar.
  const CustomAppBar({
    Key? key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.bottom,
  }) : assert(title != null || titleWidget != null), super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      leading: leading,
      title: titleWidget ?? Text(
        title!,
        style: theme.textTheme.headlineSmall,
        ),
      centerTitle: true,
      elevation: 0,
      actions: actions,
      bottom: bottom,
      surfaceTintColor: theme.colorScheme.surfaceTint,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
  );
}
