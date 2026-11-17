class HealthRecord {
  const HealthRecord({
    required this.title,
    required this.date,
    required this.description,
    this.recordCode = '',
  });

  final String title;
  final String date;
  final String description;
  final String recordCode;
}
