import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/blue_app_bar.dart';
import '../../models/health_record.dart';

class HealthVisitDetailScreen extends StatelessWidget {
  const HealthVisitDetailScreen({super.key, required this.record});

  final HealthRecord record;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy').parseStrict(record.date);
    final isDermatology = record.title.toLowerCase().contains('da liễu');
    final department = record.title.replaceFirst('Khám ', '');
    final diagnosis = isDermatology
        ? 'Viêm da tiếp xúc, theo dõi dị ứng.'
        : 'Khám sức khỏe tổng quát, chưa ghi nhận dấu hiệu bất thường.';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BlueAppBar(title: 'Chi tiết lượt khám'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _DetailSection(
            title: 'Thông tin chung',
            icon: Icons.assignment_outlined,
            child: Column(
              children: [
                _InfoRow(label: 'Mã HS', value: record.recordCode),
                _InfoRow(label: 'Ngày khám', value: record.date),
                _InfoRow(label: 'Loại', value: record.description),
                const _InfoRow(
                    label: 'Bệnh viện', value: 'BV Da liễu Trung ương'),
                _InfoRow(label: 'Khoa', value: department),
                _InfoRow(
                  label: 'Bác sĩ',
                  value: isDermatology ? 'BS. Trần Thu Hà' : 'BS. Nguyễn Minh Anh',
                  isLast: true,
                ),
              ],
            ),
          ),
          _DetailSection(
            title: 'Chẩn đoán',
            icon: Icons.medical_information_outlined,
            child: Text(diagnosis,
                style: const TextStyle(height: 1.45, fontSize: 14)),
          ),
          _DetailSection(
            title: 'Chỉ định / Dịch vụ',
            icon: Icons.list_alt_outlined,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 30, child: Text('STT', style: _tableHeaderStyle)),
                      Expanded(flex: 5, child: Text('Tên dịch vụ', style: _tableHeaderStyle)),
                      Expanded(flex: 3, child: Text('Nơi thực hiện', style: _tableHeaderStyle)),
                      Expanded(flex: 2, child: Text('Trạng thái', style: _tableHeaderStyle)),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                _ServiceRow(
                  number: '1',
                  service: isDermatology ? 'Khám chuyên khoa Da liễu' : 'Khám chuyên khoa',
                  location: 'Phòng khám',
                  status: 'Hoàn thành',
                ),
                _ServiceRow(
                  number: '2',
                  service: isDermatology ? 'Tổng phân tích tế bào máu' : 'Sinh hóa máu',
                  location: 'Khu xét nghiệm',
                  status: 'Có kết quả',
                  isLast: true,
                ),
              ],
            ),
          ),
          _DetailSection(
            title: 'Kết quả xét nghiệm',
            icon: Icons.biotech_outlined,
            child: Column(
              children: const [
                _LabResult(name: 'Bạch cầu (WBC)', value: '7.2', unit: 'G/L'),
                _LabResult(name: 'Hồng cầu (RBC)', value: '4.8', unit: 'T/L'),
                _LabResult(name: 'Hemoglobin (HGB)', value: '11.2', unit: 'g/dL', abnormal: true),
                _LabResult(name: 'Tiểu cầu (PLT)', value: '245', unit: 'G/L', isLast: true),
              ],
            ),
          ),
          _DetailSection(
            title: 'Đơn thuốc',
            icon: Icons.medication_outlined,
            child: Column(
              children: const [
                _MedicineRow(
                  name: 'Cetirizine 10 mg',
                  dosage: 'Uống 1 viên buổi tối sau ăn',
                  quantity: '5 viên',
                ),
                _MedicineRow(
                  name: 'Kem bôi da',
                  dosage: 'Bôi mỏng vùng da tổn thương, ngày 2 lần',
                  quantity: '1 tuýp',
                  isLast: true,
                ),
              ],
            ),
          ),
          _DetailSection(
            title: 'Lời dặn của bác sĩ',
            icon: Icons.chat_bubble_outline,
            child: const Text(
              'Giữ vùng da sạch và khô, tránh tiếp xúc với tác nhân gây kích ứng. Tái khám nếu triệu chứng không cải thiện sau 5 ngày.',
              style: TextStyle(height: 1.5, fontSize: 14),
            ),
          ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tính năng tải kết quả PDF sẽ sớm có')),
            ),
            icon: const Icon(Icons.download_outlined),
            label: const Text('Tải kết quả PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          Text('Lượt khám ngày ${DateFormat('dd/MM/yyyy').format(date)}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

const _tableHeaderStyle = TextStyle(
  color: AppColors.primary,
  fontSize: 10,
  fontWeight: FontWeight.w700,
);

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 13),
              child,
            ],
          ),
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 95,
              child: Text(label,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
            Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.number,
    required this.service,
    required this.location,
    required this.status,
    this.isLast = false,
  });

  final String number;
  final String service;
  final String location;
  final String status;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFE7E9ED))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 30, child: Text(number, style: const TextStyle(fontSize: 10))),
            Expanded(flex: 5, child: Text(service, style: const TextStyle(fontSize: 10, height: 1.3))),
            Expanded(flex: 3, child: Text(location, style: const TextStyle(fontSize: 10, height: 1.3))),
            Expanded(
              flex: 2,
              child: Text(status,
                  style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.secondaryGreen,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
}

class _LabResult extends StatelessWidget {
  const _LabResult({
    required this.name,
    required this.value,
    required this.unit,
    this.abnormal = false,
    this.isLast = false,
  });

  final String name;
  final String value;
  final String unit;
  final bool abnormal;
  final bool isLast;

  @override
  Widget build(BuildContext context) => _LineItem(
        isLast: isLast,
        leading: Text(name,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
        trailing: Text('$value $unit',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: abnormal ? AppColors.danger : AppColors.textPrimary)),
      );
}

class _MedicineRow extends StatelessWidget {
  const _MedicineRow({
    required this.name,
    required this.dosage,
    required this.quantity,
    this.isLast = false,
  });

  final String name;
  final String dosage;
  final String quantity;
  final bool isLast;

  @override
  Widget build(BuildContext context) => _LineItem(
        isLast: isLast,
        leading: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(dosage,
                  style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.textSecondary)),
            ],
          ),
        ),
        trailing: Text(quantity,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w700)),
      );
}

class _LineItem extends StatelessWidget {
  const _LineItem({
    required this.leading,
    required this.trailing,
    this.isLast = false,
  });

  final Widget leading;
  final Widget trailing;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFE7E9ED))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            leading,
            const SizedBox(width: 10),
            trailing,
          ],
        ),
      );
}
