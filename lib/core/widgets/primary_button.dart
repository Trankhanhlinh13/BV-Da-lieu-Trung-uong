import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.enabled = true, this.loading = false}); final String label; final VoidCallback? onPressed; final bool enabled, loading;
  @override Widget build(BuildContext context) => SizedBox(width: double.infinity, child: ElevatedButton(onPressed: enabled && !loading ? onPressed : null, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, disabledBackgroundColor: AppColors.primary.withOpacity(.45), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 15)), child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(label, style: const TextStyle(fontWeight: FontWeight.bold))));
}
