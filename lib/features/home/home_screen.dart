import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/blue_app_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../mock/mock_data.dart';
import '../booking/widgets/select_patient_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.user;
    final appointment = MockData.appointments.first;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/chatbot'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.smart_toy_outlined),
        label: const Text('Trợ lý ảo'),
      ),
      appBar: const BlueAppBar(
        title: 'BV Da liễu Trung ương',
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.support_agent),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Xin chào,',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.textSecondary)),
          Text(user.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          Card(
            color: AppColors.primary,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chăm sóc sức khỏe bắt đầu từ hôm nay',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Đặt lịch khám nhanh chóng và tiện lợi',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: 150,
                    child: FilledButton(
                      onPressed: () => showSelectPatientSheet(context),
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary),
                      child: const Text('Đặt lịch ngay'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: AppColors.secondaryGreen,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => context.push('/today'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.today_outlined,
                          color: Colors.white, size: 27),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Khám hôm nay',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16)),
                          SizedBox(height: 3),
                          Text('Xem bác sĩ còn giờ trống trong ngày',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const _SectionTitle('Chuyên khoa'),
          const SizedBox(height: 10),
          SizedBox(
            height: 112,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: MockData.departments
                  .map((department) => SizedBox(
                        width: 100,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(department.icon,
                                    style: const TextStyle(fontSize: 26)),
                                const SizedBox(height: 8),
                                Text(department.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionTitle('Lịch khám sắp tới'),
              TextButton(
                  onPressed: () => context.go('/appointments'),
                  child: const Text('Xem tất cả')),
            ],
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(appointment.department,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      StatusBadge(label: appointment.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(appointment.doctor,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('20/11/2026 • 09:30  |  Số ${appointment.number}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
              label: 'Hồ sơ sức khỏe',
              onPressed: () => context.go('/health-record')),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      );
}
