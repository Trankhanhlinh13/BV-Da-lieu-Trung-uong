import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/notification_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/blue_app_bar.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/notification_item.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final controller = ref.read(notificationProvider.notifier);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BlueAppBar(
        title: 'Thông báo',
        actions: [
          TextButton(
            onPressed: controller.markAllRead,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text(
              'Đọc tất cả',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_off_outlined,
              text: 'Chưa có thông báo',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
              itemCount: notifications.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.horizontal,
                  background: _DismissBackground(
                    alignment: Alignment.centerLeft,
                    label: 'Xóa',
                  ),
                  secondaryBackground: _DismissBackground(
                    alignment: Alignment.centerRight,
                    label: 'Xóa',
                  ),
                  onDismissed: (_) {
                    controller.remove(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Đã xóa thông báo'),
                        action: SnackBarAction(
                          label: 'Hoàn tác',
                          onPressed: () => controller.restore(item, index),
                        ),
                      ),
                    );
                  },
                  child: _NotificationCard(
                    item: item,
                    onTap: () => controller.markRead(item.id),
                  ),
                );
              },
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final NotificationItem item;
  final VoidCallback onTap;

  (IconData, Color, Color) get _iconStyle => switch (item.type) {
        NotificationType.appointment => (
            Icons.calendar_month_rounded,
            const Color(0xFFE7F1FC),
            AppColors.primary,
          ),
        NotificationType.result => (
            Icons.description_rounded,
            const Color(0xFFE6F4E9),
            AppColors.secondaryGreen,
          ),
        NotificationType.system => (
            Icons.notifications_active_rounded,
            const Color(0xFFFFF0DE),
            const Color(0xFFEA8B19),
          ),
      };

  @override
  Widget build(BuildContext context) {
    final iconStyle = _iconStyle;
    return Card(
      color: item.isRead ? Colors.white : const Color(0xFFEEF6FF),
      elevation: 1.2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: iconStyle.$2,
                child: Icon(iconStyle.$1, color: iconStyle.$3, size: 25),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.time,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (!item.isRead) ...[
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  const _DismissBackground({required this.alignment, required this.label});

  final Alignment alignment;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: alignment,
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
}
