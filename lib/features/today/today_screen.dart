import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/blue_app_bar.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  static const _filters = [
    'Tất cả',
    'Da liễu',
    'Nội khoa',
    'Tim mạch',
    'Tai Mũi Họng',
    'Sản phụ khoa',
  ];
  static const _doctors = <_TodayDoctor>[
    _TodayDoctor(
      name: 'BS. Trần Thu Hà',
      department: 'Da liễu',
      room: 'Phòng 302 - Nhà A1',
      slots: ['07:30', '08:00', '08:30', '09:00'],
      tint: Color(0xFFE4F1FF),
    ),
    _TodayDoctor(
      name: 'BS. Lê Hoàng Nam',
      department: 'Nội khoa',
      room: 'Phòng 205 - Nhà A2',
      slots: ['07:00', '07:30', '08:30', '09:30', '10:00'],
      tint: Color(0xFFE5F5EF),
    ),
    _TodayDoctor(
      name: 'BS. Nguyễn Minh Anh',
      department: 'Tim mạch',
      room: 'Phòng 410 - Nhà B',
      slots: ['08:00', '08:30', '09:00'],
      tint: Color(0xFFFFEFE5),
    ),
  ];

  String _selectedFilter = 'Tất cả';

  List<_TodayDoctor> get _visibleDoctors => _selectedFilter == 'Tất cả'
      ? _doctors
      : _doctors.where((doctor) => doctor.department == _selectedFilter).toList();

  void _openBooking(_TodayDoctor doctor, String time) {
    final today = DateTime.now();
    final date = DateFormat('yyyy-MM-dd').format(today);
    final query = Uri(queryParameters: {
      'department': doctor.department,
      'doctor': doctor.name,
      'time': time,
      'date': date,
    }).query;
    context.push('/booking?$query');
  }

  void _bookAnotherDay() => context.push('/booking');

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BlueAppBar(title: 'Khám hôm nay'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  today,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Text('Lịch trống trong ngày',
                    style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final selected = filter == _selectedFilter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: selected ? AppColors.primary : const Color(0xFFE2E4E8),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _visibleDoctors.isEmpty
                ? _TodayEmptyState(onBookAnotherDay: _bookAnotherDay)
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _visibleDoctors.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => _DoctorAvailabilityCard(
                      doctor: _visibleDoctors[index],
                      onSelectTime: (time) =>
                          _openBooking(_visibleDoctors[index], time),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DoctorAvailabilityCard extends StatelessWidget {
  const _DoctorAvailabilityCard({
    required this.doctor,
    required this.onSelectTime,
  });

  final _TodayDoctor doctor;
  final ValueChanged<String> onSelectTime;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: doctor.tint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.medical_services_outlined,
                        size: 34, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doctor.name,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 3),
                        Text(doctor.department,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 15, color: AppColors.textSecondary),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(doctor.room,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F5E8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Còn ${doctor.slots.length} suất',
                        style: const TextStyle(
                            color: AppColors.secondaryGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Giờ khám gần nhất',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: doctor.slots.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final time = doctor.slots[index];
                    return OutlinedButton(
                      onPressed: () => onSelectTime(time),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: Color(0xFFB7D4F2)),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                      child: Text(time),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
}

class _TodayEmptyState extends StatelessWidget {
  const _TodayEmptyState({required this.onBookAnotherDay});

  final VoidCallback onBookAnotherDay;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                    color: Color(0xFFEAF2FB), shape: BoxShape.circle),
                child: const Icon(Icons.event_busy_outlined,
                    size: 42, color: AppColors.primary),
              ),
              const SizedBox(height: 18),
              const Text('Hôm nay đã hết lịch trống',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onBookAnotherDay,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                ),
                child: const Text('Đặt lịch ngày khác'),
              ),
            ],
          ),
        ),
      );
}

class _TodayDoctor {
  const _TodayDoctor({
    required this.name,
    required this.department,
    required this.room,
    required this.slots,
    required this.tint,
  });

  final String name;
  final String department;
  final String room;
  final List<String> slots;
  final Color tint;
}
