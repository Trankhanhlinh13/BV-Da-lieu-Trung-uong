import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/blue_app_bar.dart';
import '../../mock/mock_data.dart';

class LookupScreen extends StatefulWidget {
  const LookupScreen({super.key});

  @override
  State<LookupScreen> createState() => _LookupScreenState();
}

class _LookupScreenState extends State<LookupScreen> {
  final _codeController = TextEditingController();

  bool get _hasCode => _codeController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _openScanner() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const _MockScannerScreen()),
    );
  }

  Future<void> _showLookupResult() async {
    if (!_hasCode) return;
    FocusManager.instance.primaryFocus?.unfocus();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _LookupResultSheet(),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: BlueAppBar(
          title: 'Tra cứu số khám',
          leading: IconButton(
            tooltip: 'Quay lại',
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
            children: [
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFD8DADE)),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        onChanged: (_) => setState(() {}),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _showLookupResult(),
                        decoration: InputDecoration(
                          filled: false,
                          hintText: 'Nhập mã hồ sơ',
                          hintStyle: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 27,
                          ),
                          suffixIcon: IconButton(
                            tooltip: 'Quét mã hồ sơ',
                            onPressed: _openScanner,
                            icon: const _ScanCodeIcon(),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 15),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      height: double.infinity,
                      child: Material(
                        color: _hasCode
                            ? AppColors.primary
                            : AppColors.primary.withOpacity(0.38),
                        child: InkWell(
                          onTap: _hasCode ? _showLookupResult : null,
                          child: const Center(
                            child: Text(
                              'Tìm',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 34),
              const Text(
                'HƯỚNG DẪN XEM MÃ HỒ SƠ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF858597),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.25,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: AspectRatio(
                  aspectRatio: 1.28,
                  child: Image.asset(
                    'assets/images/lookup_guide.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const _LookupGuidePlaceholder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _ScanCodeIcon extends StatelessWidget {
  const _ScanCodeIcon();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 26,
        height: 26,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.crop_free, color: AppColors.textPrimary, size: 26),
            Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              color: const Color(0xFFE91E63),
            ),
          ],
        ),
      );
}

class _LookupGuidePlaceholder extends StatelessWidget {
  const _LookupGuidePlaceholder();

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                'PHIẾU HƯỚNG DẪN',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Mã Hồ sơ',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  height: 42,
                  child: CustomPaint(painter: _BarcodePlaceholderPainter()),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Họ và tên: TRẦN KHÁNH LINH',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Expanded(
              child: Column(
                children: [
                  Divider(color: Color(0xFF777777)),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('STT', style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('Tên dịch vụ',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('Nơi khám',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Divider(color: Color(0xFF777777)),
                  Expanded(
                    child: Center(
                      child: Text(
                        '18       Khám nội       Khoa khám bệnh',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Minh họa phiếu có mã hồ sơ',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      );
}

class _BarcodePlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF202020);
    const pattern = '101101001110100101011101001101110010110101';
    final unit = size.width / pattern.length;
    for (var index = 0; index < pattern.length; index++) {
      if (pattern[index] == '1') {
        canvas.drawRect(
          Rect.fromLTWH(index * unit, 0, unit * 0.78, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MockScannerScreen extends StatelessWidget {
  const _MockScannerScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF101820),
        appBar: AppBar(
          backgroundColor: const Color(0xFF101820),
          foregroundColor: Colors.white,
          title: const Text('Quét mã hồ sơ'),
          centerTitle: true,
          leading: IconButton(
            tooltip: 'Đóng',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Đưa mã hồ sơ vào khung để quét',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 26),
              Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70, width: 2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2,
                        color: const Color(0xFFE91E63),
                      ),
                    ),
                    const Icon(
                      Icons.qr_code_2,
                      color: Colors.white24,
                      size: 180,
                    ),
                    const _ScannerCorners(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tính năng quét mã đang ở chế độ minh họa',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
}

class _ScannerCorners extends StatelessWidget {
  const _ScannerCorners();

  @override
  Widget build(BuildContext context) => const CustomPaint(
        size: Size(270, 270),
        painter: _ScannerCornerPainter(),
      );
}

class _ScannerCornerPainter extends CustomPainter {
  const _ScannerCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    const length = 34.0;
    final corners = <(Offset, Offset, Offset)>[
      (const Offset(3, 3), const Offset(length, 3), const Offset(3, length)),
      (Offset(size.width - 3, 3), Offset(size.width - length, 3),
          Offset(size.width - 3, length)),
      (Offset(3, size.height - 3), Offset(length, size.height - 3),
          Offset(3, size.height - length)),
      (Offset(size.width - 3, size.height - 3),
          Offset(size.width - length, size.height - 3),
          Offset(size.width - 3, size.height - length)),
    ];
    for (final corner in corners) {
      canvas.drawLine(corner.$1, corner.$2, paint);
      canvas.drawLine(corner.$1, corner.$3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LookupResultSheet extends StatelessWidget {
  const _LookupResultSheet();

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Kết quả tra cứu',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 18),
              _ResultRow(label: 'STT khám', value: '18'),
              _ResultRow(label: 'Họ tên', value: MockData.user.name),
              const _ResultRow(label: 'Dịch vụ', value: 'Khám nội'),
              const _ResultRow(label: 'Nơi khám', value: 'Khoa khám bệnh'),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        ),
      );
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
}
