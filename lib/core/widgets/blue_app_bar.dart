import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BlueAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BlueAppBar({super.key, required this.title, this.actions, this.leading});
  final String title; final List<Widget>? actions; final Widget? leading;
  @override Widget build(BuildContext context) => AppBar(title: Text(title), backgroundColor: AppColors.primary, foregroundColor: Colors.white, centerTitle: true, actions: actions, leading: leading);
  @override Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
