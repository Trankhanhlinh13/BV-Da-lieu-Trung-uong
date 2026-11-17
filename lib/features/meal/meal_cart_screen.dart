import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/blue_app_bar.dart';
import '../../models/meal_order.dart';

class MealCartScreen extends StatefulWidget {
  const MealCartScreen({super.key, required this.payload});

  final MealCartPayload payload;

  @override
  State<MealCartScreen> createState() => _MealCartScreenState();
}

class _MealCartScreenState extends State<MealCartScreen> {
  late final List<MealCartLine> _lines;
  final _noteController = TextEditingController();
  final _roomController = TextEditingController();
  final _bedController = TextEditingController();

  int get _total => _lines.fold(0, (sum, line) => sum + line.item.price * line.quantity);

  @override
  void initState() {
    super.initState();
    _lines = List.of(widget.payload.lines);
  }

  @override
  void dispose() {
    _noteController.dispose();
    _roomController.dispose();
    _bedController.dispose();
    super.dispose();
  }

  void _changeQuantity(int index, int delta) {
    setState(() {
      final next = _lines[index].quantity + delta;
      if (next <= 0) {
        _lines.removeAt(index);
      } else {
        _lines[index] = _lines[index].copyWith(quantity: next);
      }
    });
  }

  Future<void> _placeOrder() async {
    if (_lines.isEmpty) return;
    final code = 'MA-${DateFormat('yyyyMMdd').format(DateTime.now())}-0042';
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.statusOutpatient,
              child: Icon(Icons.check_rounded,
                  size: 42, color: AppColors.secondaryGreen),
            ),
            const SizedBox(height: 16),
            const Text('Đặt suất ăn thành công',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Mã đơn: $code',
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 5),
            Text('Người nhận: ${widget.payload.recipientName}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hoàn tất'),
          ),
        ],
      ),
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat('#,##0', 'vi_VN');
    final date = DateFormat('dd/MM/yyyy').format(widget.payload.date);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BlueAppBar(
        title: 'Giỏ suất ăn',
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Quay lại',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          _SectionCard(
            title: 'Thông tin nhận suất ăn',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoLine(icon: Icons.person_outline, text: widget.payload.recipientName),
                const SizedBox(height: 8),
                _InfoLine(icon: Icons.calendar_today_outlined, text: '$date • Bữa ${widget.payload.meal}'),
              ],
            ),
          ),
          _SectionCard(
            title: 'Món đã chọn (${_lines.length})',
            child: _lines.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Giỏ hàng đang trống',
                        style: TextStyle(color: AppColors.textSecondary)),
                  )
                : Column(
                    children: [
                      for (var index = 0; index < _lines.length; index++) ...[
                        if (index > 0)
                          const Divider(height: 18, color: Color(0xFFE8E9EC)),
                        _CartLineTile(
                          line: _lines[index],
                          price: '${money.format(_lines[index].item.price * _lines[index].quantity)}đ',
                          onDecrease: () => _changeQuantity(index, -1),
                          onIncrease: () => _changeQuantity(index, 1),
                          onRemove: () => setState(() => _lines.removeAt(index)),
                        ),
                      ],
                    ],
                  ),
          ),
          _SectionCard(
            title: 'Ghi chú',
            child: TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Dị ứng, ăn kiêng hoặc lưu ý khác',
                filled: true,
                fillColor: const Color(0xFFF6F7F8),
                contentPadding: const EdgeInsets.all(13),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          _SectionCard(
            title: 'Vị trí giao suất ăn',
            child: Row(
              children: [
                Expanded(
                  child: _LocationField(
                    controller: _roomController,
                    label: 'Số phòng',
                    hint: 'VD: 302',
                    icon: Icons.meeting_room_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LocationField(
                    controller: _bedController,
                    label: 'Giường',
                    hint: 'VD: 02',
                    icon: Icons.bed_outlined,
                  ),
                ),
              ],
            ),
          ),
          Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng tiền', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('${money.format(_total)}đ',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _lines.isEmpty ? null : _placeOrder,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Đặt suất ăn',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      );
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({
    required this.line,
    required this.price,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final MealCartLine line;
  final String price;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
                color: line.item.color,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(line.item.icon, color: AppColors.secondaryGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.item.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(price,
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ],
            ),
          ),
          IconButton(
              onPressed: onRemove,
              visualDensity: VisualDensity.compact,
              tooltip: 'Xóa món',
              icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20)),
          _CartQuantity(quantity: line.quantity, onDecrease: onDecrease, onIncrease: onIncrease),
        ],
      );
}

class _CartQuantity extends StatelessWidget {
  const _CartQuantity({required this.quantity, required this.onDecrease, required this.onIncrease});
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SmallAction(icon: Icons.remove, onPressed: onDecrease),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          _SmallAction(icon: Icons.add, onPressed: onIncrease),
        ],
      );
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 25,
        height: 25,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: Icon(icon, size: 15),
          style: IconButton.styleFrom(
            foregroundColor: AppColors.primary,
            backgroundColor: const Color(0xFFEAF2FB),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          ),
        ),
      );
}

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 18),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE1E3E7))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary)),
        ),
      );
}
