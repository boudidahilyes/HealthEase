import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool leading;

  const CustomAppBar(this.leading, {super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      backgroundColor: colorScheme.onPrimary,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: leading,
      title: Image.asset('assets/images/health_ease_logo.png', height: 130),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}