import '../models/appointment.dart';
import '../models/department.dart';
import '../models/doctor.dart';
import '../models/health_record.dart';
import '../models/notification_item.dart';
import '../models/user_profile.dart';

abstract final class MockData {
  static final user = UserProfile(name: 'TRẦN KHÁNH LINH', phone: '0357959848', birthDate: DateTime(2006, 1, 13), gender: 'Nữ');
  static final familyMembers = <UserProfile>[
    UserProfile(
      name: 'TRẦN THỊ MAI',
      phone: '0912345678',
      birthDate: DateTime(1978, 5, 20),
      gender: 'Nữ',
      isOwner: false,
    ),
  ];
  static final mealMembers = <UserProfile>[
    user,
    UserProfile(
      name: user.name,
      phone: user.phone,
      birthDate: user.birthDate,
      gender: user.gender,
      isOwner: false,
    ),
  ];
  static const departments = [Department(name: 'Tim mạch', icon: '❤️'), Department(name: 'Nhi khoa', icon: '🧸'), Department(name: 'Da liễu', icon: '✨'), Department(name: 'Thần kinh', icon: '🧠')];
  static const doctors = [Doctor(name: 'BS. Nguyễn Minh Anh', specialty: 'Tim mạch', experience: '12 năm kinh nghiệm'), Doctor(name: 'BS. Lê Hoàng Nam', specialty: 'Nội tổng quát', experience: '8 năm kinh nghiệm')];
  static final appointments = [
    Appointment(
      id: 'AT-2026-1120',
      department: 'Da liễu',
      doctor: 'BS. Trần Thu Hà',
      dateTime: DateTime(2026, 11, 20, 6, 30),
      status: 'Đã duyệt',
    ),
    Appointment(
      id: 'AT-2026-0919',
      department: 'Da liễu',
      doctor: 'BS. Trần Thu Hà',
      dateTime: DateTime(2026, 9, 19, 6),
      status: 'Đã có số khám',
      number: 'A019',
    ),
    Appointment(
      id: 'AT-2026-0226',
      department: 'Da liễu',
      doctor: 'BS. Trần Thu Hà',
      dateTime: DateTime(2026, 2, 26, 6, 30),
      status: 'Đã có số khám',
      number: 'A026',
    ),
  ];
  static const records = [
    HealthRecord(
      title: 'Khám Da liễu',
      date: '19/09/2026',
      description: 'Ngoại trú',
      recordCode: '2609191881',
    ),
    HealthRecord(
      title: 'Khám Nội khoa',
      date: '08/09/2026',
      description: 'Ngoại trú',
      recordCode: '2609081200',
    ),
    HealthRecord(
      title: 'Khám Da liễu',
      date: '16/08/2026',
      description: 'Ngoại trú',
      recordCode: '2608161001',
    ),
    HealthRecord(
      title: 'Khám Tim mạch',
      date: '22/06/2026',
      description: 'Ngoại trú',
      recordCode: '2606229988',
    ),
    HealthRecord(
      title: 'Khám Nội khoa',
      date: '23/05/2026',
      description: 'Ngoại trú',
      recordCode: '2605238300',
    ),
    HealthRecord(
      title: 'Khám Da liễu',
      date: '10/03/2026',
      description: 'Ngoại trú',
      recordCode: '2603104106',
    ),
  ];
  static const notifications = [
    NotificationItem(
      id: 'notice-appointment-approved',
      title: 'Lịch khám đã được duyệt',
      message: 'Lịch khám ngày 20/11/2026 lúc 06:30 đã được duyệt.',
      time: '2 giờ trước',
      type: NotificationType.appointment,
    ),
    NotificationItem(
      id: 'notice-appointment-reminder',
      title: 'Nhắc lịch khám',
      message: 'Bạn có lịch khám Da liễu vào ngày 20/11/2026 lúc 06:30.',
      time: '5 giờ trước',
      type: NotificationType.appointment,
    ),
    NotificationItem(
      id: 'notice-result-ready',
      title: 'Kết quả khám đã có',
      message: 'Kết quả khám ngày 19/09/2026 đã được cập nhật vào hồ sơ.',
      time: 'Hôm qua',
      type: NotificationType.result,
    ),
    NotificationItem(
      id: 'notice-appointment-number',
      title: 'Đã có số khám',
      message: 'Số thứ tự khám của bạn là 18 tại Khoa khám bệnh.',
      time: '2 ngày trước',
      type: NotificationType.appointment,
      isRead: true,
    ),
    NotificationItem(
      id: 'notice-system-update',
      title: 'Thông báo hệ thống',
      message: 'Ứng dụng đã được cập nhật để cải thiện trải nghiệm đặt lịch.',
      time: '3 ngày trước',
      type: NotificationType.system,
      isRead: true,
    ),
    NotificationItem(
      id: 'notice-profile-updated',
      title: 'Hồ sơ sức khỏe đã cập nhật',
      message: 'Một lượt khám mới đã được thêm vào hồ sơ sức khỏe của bạn.',
      time: '1 tuần trước',
      type: NotificationType.result,
    ),
  ];
}
