import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/blue_app_bar.dart';
import '../../core/widgets/empty_state.dart';
import 'widgets/appointment_card.dart';
import '../../mock/mock_data.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: BlueAppBar(
            title: 'Lịch khám',
            leading: IconButton(
              tooltip: 'Quay lại',
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: Column(
            children: [
              Material(
                color: Colors.white,
                child: TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.35,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.35,
                  ),
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: 'LỊCH KHÁM'),
                    Tab(text: 'LỊCH TÁI KHÁM'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _AppointmentList(),
                    const EmptyState(
                      icon: Icons.event_available_outlined,
                      text: 'Chưa có lịch tái khám',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _AppointmentList extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
        itemCount: MockData.appointments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => AppointmentCard(
          appointment: MockData.appointments[index],
          patientName: MockData.user.name,
        ),
      );
}
