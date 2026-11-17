class MarkerData {
  const MarkerData({
    required this.id,
    required this.label,
    required this.name,
    required this.x,
    required this.y,
    required this.category,
    required this.rooms,
    this.isCluster = false,
  });

  final String id;
  final String label;
  final String name;
  final double x;
  final double y;
  final String category;
  final List<String> rooms;
  final bool isCluster;
}
