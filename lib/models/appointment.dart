class Appointment {
  const Appointment({required this.id, required this.department, required this.doctor, required this.dateTime, required this.status, this.number});
  final String id, department, doctor, status;
  final DateTime dateTime;
  final String? number;
}
