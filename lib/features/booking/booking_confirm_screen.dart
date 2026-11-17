import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/blue_app_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/booking_draft.dart';

class BookingConfirmScreen extends StatelessWidget {
  const BookingConfirmScreen({super.key, required this.draft});

  final BookingDraft draft;

  String get _formattedDateTime {
    final date = DateFormat('dd/MM/yyyy').format(draft.appointmentDateTime);
    final time = DateFormat('HH:mm').format(draft.appointmentDateTime);
    return '$date • $time';
  }

  void _confirm(BuildContext context) {
    final code =
        'LH-${DateFormat('yyMMdd').format(draft.appointmentDateTime)}-0042';
    context.push('/booking/success', extra: draft.copyWith(appointmentCode: code));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: BlueAppBar(
          title: 'Xác nhận đặt lịch',
          leading: IconButton(
            tooltip: 'Quay lại',
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin lịch khám',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 18),
                    _SummaryRow(label: 'Người khám', value: draft.patientName),
                    _SummaryRow(label: 'Khoa', value: draft.department),
                    _SummaryRow(label: 'Bác sĩ', value: draft.doctor),
                    _SummaryRow(label: 'Ngày giờ', value: _formattedDateTime),
                    _SummaryRow(label: 'Cơ sở', value: draft.facility),
                    const SizedBox(height: 8),
                    const Text(
                      'Vấn đề sức khỏe',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      draft.healthConcern,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ảnh đính kèm',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 9),
                    if (draft.attachments.isEmpty)
                      const Text(
                        'Chưa có ảnh đính kèm',
                        style: TextStyle(color: AppColors.textSecondary),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: draft.attachments
                            .map((attachment) => _AttachmentThumbnail(
                                  label: attachment,
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Lưu ý',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _NoteLine(text: 'Vui lòng đến sớm 15 phút trước giờ khám.'),
                    const SizedBox(height: 7),
                    _NoteLine(text: 'Mang theo CCCD và thẻ BHYT (nếu có).'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: PrimaryButton(
              label: 'Xác nhận đặt lịch',
              onPressed: () => _confirm(context),
            ),
          ),
        ),
      );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 95,
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
}

class _AttachmentThumbnail extends StatelessWidget {
  const _AttachmentThumbnail({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: const Color(0xFFE7F1FC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD7E4F2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined,
                size: 29, color: AppColors.primary),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
      );
}

class _NoteLine extends StatelessWidget {
  const _NoteLine({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      );
}
