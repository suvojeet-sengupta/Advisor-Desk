import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    Key? key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.bottom,
    this.automaticallyImplyLeading = true,
  }) : assert(title != null || titleWidget != null), super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
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
