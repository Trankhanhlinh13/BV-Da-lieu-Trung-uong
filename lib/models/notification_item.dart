enum NotificationType { appointment, result, system }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.type = NotificationType.system,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  final bool isRead;

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        title: title,
        message: message,
        time: time,
        type: type,
        isRead: isRead ?? this.isRead,
      );
}
