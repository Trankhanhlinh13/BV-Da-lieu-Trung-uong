import 'package:flutter/material.dart';
class EmptyState extends StatelessWidget { const EmptyState({super.key, required this.icon, required this.text}); final IconData icon; final String text;
  @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 56, color: const Color(0xFF8A8A99)), const SizedBox(height: 12), Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF8A8A99)))])));
}
