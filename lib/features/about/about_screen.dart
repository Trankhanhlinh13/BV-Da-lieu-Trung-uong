import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/blue_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launch(BuildContext context, Uri uri) async {
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở ứng dụng liên kết')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: const BlueAppBar(title: 'Về BV Da liễu Trung ương'),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 190,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/hospital_cover.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF6EA6E8), AppColors.primary],
                          ),
                        ),
                        child: Center(
                          child: Icon(Icons.local_hospital_outlined,
                              size: 76, color: Colors.white),
                        ),
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0xB800284F)],
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 18,
                      right: 18,
                      bottom: 16,
                      child: Text(
                        'BV Da liễu Trung ương',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _InfoCard(
              title: 'Giới thiệu',
              icon: Icons.info_outline,
              child: const Text(
                'BV Da liễu Trung ương là bệnh viện chuyên khoa đầu ngành về da liễu, cung cấp dịch vụ khám, chẩn đoán và điều trị các bệnh lý về da.',
                style: TextStyle(color: AppColors.textSecondary, height: 1.5),
              ),
            ),
            _InfoCard(
              title: 'Thông tin liên hệ',
              icon: Icons.contact_phone_outlined,
              child: Column(
                children: [
                  const _InfoLine(
                    icon: Icons.access_time,
                    title: 'Giờ làm việc',
                    value: 'Thứ Hai – Thứ Bảy, 07:00 – 17:00',
                  ),
                  const SizedBox(height: 13),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.primary, size: 19),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Địa chỉ',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                            SizedBox(height: 3),
                            Text('Số 15A Phương Mai, Đống Đa, Hà Nội',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/map'),
                        child: const Text('Chỉ đường'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _launch(context,
                        Uri(scheme: 'tel', path: '19006422')),
                    child: const _InfoLine(
                      icon: Icons.phone_outlined,
                      title: 'Hotline',
                      value: '1900 6422',
                      valueColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 13),
                  InkWell(
                    onTap: () => _launch(context, Uri(
                      scheme: 'mailto',
                      path: 'benhvien@hmu.edu.vn',
                    )),
                    child: const _InfoLine(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: 'benhvien@hmu.edu.vn',
                      valueColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 13),
                  InkWell(
                    onTap: () => _launch(context,
                        Uri.parse('https://benhviendaihocyhanoi.com')),
                    child: const _InfoLine(
                      icon: Icons.language,
                      title: 'Website',
                      value: 'benhviendaihocyhanoi.com',
                      valueColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            _InfoCard(
              title: 'Chuyên khoa nổi bật',
              icon: Icons.medical_services_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  'Tim mạch',
                  'Da liễu',
                  'Nội khoa',
                  'Nhi khoa',
                  'Thần kinh',
                  'Tai Mũi Họng',
                  'Sản phụ khoa',
                  'Cơ xương khớp',
                ].map((name) => _DepartmentChip(name: name)).toList(),
              ),
            ),
          ],
        ),
      );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
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
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 13),
              child,
            ],
          ),
        ),
      );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor = AppColors.textPrimary,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 3),
                Text(value,
                    style: TextStyle(
                        color: valueColor, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      );
}

class _DepartmentChip extends StatelessWidget {
  const _DepartmentChip({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2FB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(name,
            style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      );
}
