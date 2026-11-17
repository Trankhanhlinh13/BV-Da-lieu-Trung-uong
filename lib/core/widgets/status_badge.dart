import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label}); final String label;
  @override Widget build(BuildContext context) { final (Color, Color) style = switch (label) { 'Đã duyệt' => (AppColors.statusApproved, const Color(0xFF7146B5)), 'Đã có số khám' || 'Đã lấy số' => (AppColors.statusHasNumber, const Color(0xFF16B9C4)), 'Ngoại trú' => (AppColors.statusOutpatient, AppColors.secondaryGreen), _ => (const Color(0xFFF1F2F4), AppColors.textSecondary) }; return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: style.$1, borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(color: style.$2, fontSize: 12, fontWeight: FontWeight.w700))); }
}
