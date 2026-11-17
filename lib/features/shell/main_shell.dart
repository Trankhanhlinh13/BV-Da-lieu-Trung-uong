import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/notification_state.dart';
import '../../core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    (Icons.home_outlined, 'Trang chủ'),
    (Icons.calendar_month_outlined, 'Lịch hẹn'),
    (Icons.notifications_none, 'Thông báo'),
    (Icons.person_outline, 'Cá nhân'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: navigationShell,
        bottomNavigationBar: Consumer(
          builder: (context, ref, _) {
            final unreadCount = ref
                .watch(notificationProvider)
                .where((notification) => !notification.isRead)
                .length;
            return SafeArea(
              child: Container(
                height: 70,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: Row(
                  children: List.generate(_items.length, (index) {
                    final selected = navigationShell.currentIndex == index;
                    return Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => navigationShell.goBranch(
                          index,
                          initialLocation: index == navigationShell.currentIndex,
                        ),
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: EdgeInsets.symmetric(
                              horizontal: selected ? 13 : 8,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _items[index].$1,
                                      size: 21,
                                      color: selected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                    ),
                                    if (selected) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        _items[index].$2,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                if (index == 2 && unreadCount > 0)
                                  Positioned(
                                    right: -9,
                                    top: -7,
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 17,
                                        minHeight: 17,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        color: AppColors.danger,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        unreadCount > 9
                                            ? '9+'
                                            : '$unreadCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          },
        ),
      );
}
