import 'package:flutter/material.dart';
class OutlineMenuButton extends StatelessWidget {
  const OutlineMenuButton({super.key, required this.icon, required this.label, required this.onPressed});
  final IconData icon; final String label; final VoidCallback onPressed;
  @override Widget build(BuildContext context) => OutlinedButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0B5CB5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)));
}
