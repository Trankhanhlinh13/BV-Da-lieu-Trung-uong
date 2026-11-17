import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../mock/mock_data.dart';
import '../../models/notification_item.dart';

class NotificationController extends Notifier<List<NotificationItem>> {
  @override
  List<NotificationItem> build() => List.of(MockData.notifications);

  int get unreadCount => state.where((item) => !item.isRead).length;

  void markRead(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(isRead: true) else item,
    ];
  }

  void markAllRead() {
    state = [for (final item in state) item.copyWith(isRead: true)];
  }

  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void restore(NotificationItem item, int index) {
    if (state.any((current) => current.id == item.id)) return;
    final updated = List<NotificationItem>.of(state);
    final insertAt = index.clamp(0, updated.length).toInt();
    updated.insert(insertAt, item);
    state = updated;
  }
}

final notificationProvider =
    NotifierProvider<NotificationController, List<NotificationItem>>(
  NotificationController.new,
);
