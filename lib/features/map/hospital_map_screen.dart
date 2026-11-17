import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../mock/mock_map_data.dart';
import '../../models/marker_data.dart';

class HospitalMapScreen extends StatefulWidget {
  const HospitalMapScreen({super.key});

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  Set<String> _activeCategories = {'Khu khám bệnh', 'Điểm dịch vụ'};
  String _selectedMap = 'Bản đồ tổng thể';

  List<MarkerData> get _visibleMarkers => MockMapData.markers.where((marker) {
        final matchesCategory = _activeCategories.contains(marker.category);
        final text = '${marker.label} ${marker.name}'.toLowerCase();
        return matchesCategory && text.contains(_query.trim().toLowerCase());
      }).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showMarker(MarkerData marker) => showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.white,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  marker.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  marker.category,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Danh sách phòng / địa điểm',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                ...marker.rooms.map(
                  (room) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.meeting_room_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(room),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> _showFilters() async {
    final categories = await showModalBottomSheet<Set<String>>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MapFilterSheet(selected: _activeCategories),
    );
    if (categories != null && mounted) {
      setState(() => _activeCategories = categories);
    }
  }

  Future<void> _showMapChoices() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text(
                'Chọn bản đồ',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
            ),
            for (final option in const [
              'Bản đồ tổng thể',
              'Khu khám bệnh',
            ])
              ListTile(
                leading: const Icon(Icons.map_outlined, color: AppColors.primary),
                title: Text(option),
                trailing: option == _selectedMap
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (choice != null && mounted) setState(() => _selectedMap = choice);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF9F9FB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9F9FB),
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Bản đồ bệnh viện',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          leading: IconButton(
            tooltip: 'Quay lại',
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.chevron_left, size: 34),
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 70,
              color: const Color(0xFFF0F0F4),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: _showMapChoices,
                    borderRadius: BorderRadius.circular(10),
                    child: const SizedBox(
                      width: 70,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _MapSwapIcon(),
                          Text('Đổi bản đồ', style: TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Center(
                      child: Text(
                        _selectedMap == 'Bản đồ tổng thể'
                            ? 'BV Da liễu Trung ương'
                            : 'Khu khám bệnh — BV Da liễu Trung ương',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 76),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final markers = _visibleMarkers;
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          boundaryMargin: const EdgeInsets.all(120),
                          child: SizedBox(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  'assets/images/hospital_map.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const CustomPaint(
                                    painter: _MapFallbackPainter(),
                                  ),
                                ),
                                for (final marker in markers)
                                  Positioned(
                                    left: marker.x * constraints.maxWidth,
                                    top: marker.y * constraints.maxHeight,
                                    child: Transform.translate(
                                      offset: marker.isCluster
                                          ? const Offset(-28, -28)
                                          : const Offset(-24, -24),
                                      child: _MapMarker(
                                        marker: marker,
                                        onTap: () => _showMarker(marker),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 78,
                        top: 16,
                        child: Material(
                          color: Colors.white,
                          elevation: 3,
                          shadowColor: Colors.black26,
                          borderRadius: BorderRadius.circular(30),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() => _query = value),
                            decoration: InputDecoration(
                              hintText: 'Tìm phòng khám',
                              hintStyle: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 17,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.textSecondary,
                                size: 27,
                              ),
                              suffixIcon: _query.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Xóa tìm kiếm',
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _query = '');
                                      },
                                      icon: const Icon(Icons.close),
                                    ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Material(
                          color: Colors.white,
                          elevation: 3,
                          shadowColor: Colors.black26,
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: 'Lọc bản đồ',
                            onPressed: _showFilters,
                            icon: const Icon(
                              Icons.tune,
                              color: AppColors.textSecondary,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 10,
                        bottom: 12,
                        child: _MapAttribution(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.marker, required this.onTap});

  final MarkerData marker;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(marker.isCluster ? 40 : 8),
          child: Container(
            width: marker.isCluster ? 56 : 48,
            height: marker.isCluster ? 56 : 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(marker.isCluster ? 40 : 8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              marker.label,
              style: TextStyle(
                color: Colors.white,
                fontSize: marker.isCluster ? 28 : 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
}

class _MapSwapIcon extends StatelessWidget {
  const _MapSwapIcon();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 34,
        height: 28,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(
              left: 0,
              top: 0,
              child: Icon(Icons.location_on_outlined, size: 18),
            ),
            const Positioned(
              right: 0,
              bottom: 0,
              child: Icon(Icons.location_on, size: 18),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              color: const Color(0xFFF0F0F4),
              child: const Icon(Icons.swap_horiz, size: 19),
            ),
          ],
        ),
      );
}

class _MapAttribution extends StatelessWidget {
  const _MapAttribution();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF8D218C),
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Text(
          'InMapz',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      );
}

class _MapFilterSheet extends StatefulWidget {
  const _MapFilterSheet({required this.selected});

  final Set<String> selected;

  @override
  State<_MapFilterSheet> createState() => _MapFilterSheetState();
}

class _MapFilterSheetState extends State<_MapFilterSheet> {
  late final Set<String> _selected = {...widget.selected};
  static const _categories = ['Khu khám bệnh', 'Điểm dịch vụ'];

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lọc địa điểm',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              for (final category in _categories)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _selected.contains(category),
                  activeColor: AppColors.primary,
                  title: Text(category),
                  onChanged: (value) => setState(() {
                    if (value ?? false) {
                      _selected.add(category);
                    } else {
                      _selected.remove(category);
                    }
                  }),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(_selected),
                  child: const Text('Áp dụng'),
                ),
              ),
            ],
          ),
        ),
      );
}

class _MapFallbackPainter extends CustomPainter {
  const _MapFallbackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF4F0E3),
    );
    final river = Paint()
      ..color = const Color(0xFF70CFF1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.055;
    final riverPath = Path()
      ..moveTo(size.width * 0.56, -20)
      ..cubicTo(
        size.width * 0.43,
        size.height * 0.26,
        size.width * 0.70,
        size.height * 0.52,
        size.width * 0.53,
        size.height * 0.78,
      )
      ..cubicTo(
        size.width * 0.45,
        size.height * 0.90,
        size.width * 0.68,
        size.height,
        size.width * 0.62,
        size.height + 20,
      );
    canvas.drawPath(riverPath, river);

    final roadOutline = Paint()
      ..color = const Color(0xFFD9D7D0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;
    final road = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    final roads = <Path>[
      Path()
        ..moveTo(-10, size.height * 0.22)
        ..lineTo(size.width * 0.40, size.height * 0.28)
        ..lineTo(size.width + 10, size.height * 0.18),
      Path()
        ..moveTo(-10, size.height * 0.58)
        ..lineTo(size.width * 0.38, size.height * 0.48)
        ..lineTo(size.width + 10, size.height * 0.60),
      Path()
        ..moveTo(size.width * 0.12, -10)
        ..lineTo(size.width * 0.18, size.height * 0.48)
        ..lineTo(size.width * 0.08, size.height + 10),
      Path()
        ..moveTo(size.width * 0.82, -10)
        ..lineTo(size.width * 0.74, size.height * 0.50)
        ..lineTo(size.width * 0.92, size.height + 10),
    ];
    for (final path in roads) {
      canvas.drawPath(path, roadOutline);
      canvas.drawPath(path, road);
    }

    final buildingPaint = Paint()..color = const Color(0xFFBDA9A8);
    final parkPaint = Paint()..color = const Color(0xFF72AD5C);
    for (var row = 0; row < 6; row++) {
      for (var col = 0; col < 4; col++) {
        final rect = Rect.fromLTWH(
          size.width * (0.08 + col * 0.11),
          size.height * (0.68 + row * 0.045),
          size.width * 0.075,
          size.height * 0.025,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          (row == 3 && col == 2) ? parkPaint : buildingPaint,
        );
      }
    }
    final labelPainter = TextPainter(
      text: const TextSpan(
        text: 'BỆNH VIỆN\nĐẠI HỌC Y',
        style: TextStyle(
          color: Color(0xFF493D3D),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    labelPainter.paint(
      canvas,
      Offset(size.width * 0.30, size.height * 0.82),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
