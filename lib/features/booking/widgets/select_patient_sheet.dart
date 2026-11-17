import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

/// Opens the patient chooser over the current page, dimming the background.
Future<void> showSelectPatientSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (sheetContext) => _SelectPatientSheet(
      onSelectSelf: () {
        Navigator.of(sheetContext).pop();
        context.go(Uri(
          path: '/booking',
          queryParameters: const {'patient': 'owner'},
        ).toString());
      },
      onSelectRelative: () {
        Navigator.of(sheetContext).pop();
        context.go(Uri(
          path: '/booking',
          queryParameters: const {
            'patient': 'family',
            'selectMember': 'true',
          },
        ).toString());
      },
    ),
  );
}

class _SelectPatientSheet extends StatelessWidget {
  const _SelectPatientSheet({
    required this.onSelectSelf,
    required this.onSelectRelative,
  });

  final VoidCallback onSelectSelf;
  final VoidCallback onSelectRelative;

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCACDD2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Chọn người khám bệnh',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Đóng',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _PatientChoiceCard(
                        icon: Icons.person_rounded,
                        label: 'Cho chính mình',
                        onTap: onSelectSelf,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _PatientChoiceCard(
                        icon: Icons.groups_rounded,
                        label: 'Cho người thân',
                        onTap: onSelectRelative,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
}

class _PatientChoiceCard extends StatelessWidget {
  const _PatientChoiceCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: 0.96,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 1.4),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 104,
                    height: 104,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFD9EBFC),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: AppColors.primary, size: 66),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
