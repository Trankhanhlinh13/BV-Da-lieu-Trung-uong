class BookingDraft {
  const BookingDraft({
    required this.patientName,
    required this.department,
    required this.doctor,
    required this.appointmentDateTime,
    required this.facility,
    required this.healthConcern,
    required this.attachments,
    this.appointmentCode,
  });

  final String patientName;
  final String department;
  final String doctor;
  final DateTime appointmentDateTime;
  final String facility;
  final String healthConcern;
  final List<String> attachments;
  final String? appointmentCode;

  BookingDraft copyWith({String? appointmentCode}) => BookingDraft(
        patientName: patientName,
        department: department,
        doctor: doctor,
        appointmentDateTime: appointmentDateTime,
        facility: facility,
        healthConcern: healthConcern,
        attachments: attachments,
        appointmentCode: appointmentCode ?? this.appointmentCode,
      );
}
