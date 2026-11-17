import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/appointment.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.patientName,
  });

  final Appointment appointment;
  final String patientName;

  @override
  Widget build(BuildContext context) {
    final date = appointment.dateTime;
    final hasNumber = appointment.status == 'Đã có số khám';
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 94,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        date.day.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          color: Color(0xFFA7C6E4),
                          fontSize: 62,
                          height: 0.95,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${date.month.toString().padLeft(2, '0')}/${date.year}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 145,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  color: const Color(0xFFE6E7EA),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          patientName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'BV Da liễu Trung ương',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Khám ${appointment.department} [PK]',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        StatusBadge(label: appointment.status),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: hasNumber
                    ? () => _showReviewSheet(context)
                    : () => _showCancelDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      hasNumber ? AppColors.primary : AppColors.textPrimary,
                  side: BorderSide(
                    color: hasNumber
                        ? AppColors.primary
                        : const Color(0xFF9A9AA2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: hasNumber
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: Color(0xFFFF9D18), size: 21),
                          SizedBox(width: 7),
                          Text('Đánh giá'),
                        ],
                      )
                    : const Text('Hủy lịch'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.event_busy_outlined,
              color: AppColors.primary, size: 38),
          title: const Text('Xác nhận hủy lịch'),
          content: const Text('Bạn có chắc chắn muốn hủy lịch khám này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Giữ lịch'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã ghi nhận yêu cầu hủy (demo)')),
                );
              },
              child: const Text('Xác nhận hủy'),
            ),
          ],
      ),
    );
  }

  Future<void> _showReviewSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      builder: (_) => const _AppointmentReviewSheet(),
    );
  }
}

class _AppointmentReviewSheet extends StatefulWidget {
  const _AppointmentReviewSheet();

  @override
  State<_AppointmentReviewSheet> createState() =>
      _AppointmentReviewSheetState();
}

class _AppointmentReviewSheetState extends State<_AppointmentReviewSheet> {
  final _commentController = TextEditingController();
  int _rating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            4,
            24,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Đánh giá buổi khám',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => IconButton(
                    onPressed: () => setState(() => _rating = index + 1),
                    iconSize: 34,
                    color: index < _rating
                        ? const Color(0xFFFF9D18)
                        : const Color(0xFFD9DDE3),
                    icon: const Icon(Icons.star),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Nhận xét của bạn (không bắt buộc)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _rating == 0
                    ? null
                    : () {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.of(context).pop();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Cảm ơn bạn đã đánh giá (demo)'),
                          ),
                        );
                      },
                child: const Text('Gửi đánh giá'),
              ),
            ],
          ),
        ),
      );
}
