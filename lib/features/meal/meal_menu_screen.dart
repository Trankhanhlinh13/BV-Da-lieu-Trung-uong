import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/blue_app_bar.dart';
import '../../models/meal_order.dart';

const _mealOptions = ['Sáng', 'Trưa', 'Tối'];
const _menuItems = <MealMenuItem>[
  MealMenuItem(id: 'm1', name: 'Phở bò', description: 'Phở bò nấu mềm, nước dùng thanh', price: 45000, icon: Icons.ramen_dining, color: Color(0xFFFFE8D2)),
  MealMenuItem(id: 'm2', name: 'Cơm gà rau củ', description: 'Cơm mềm, ức gà và rau củ luộc', price: 55000, icon: Icons.dinner_dining, color: Color(0xFFE8F3DA)),
  MealMenuItem(id: 'm3', name: 'Cháo thịt bằm', description: 'Cháo dinh dưỡng, dễ tiêu hóa', price: 35000, icon: Icons.soup_kitchen, color: Color(0xFFFFF0CB)),
  MealMenuItem(id: 'm4', name: 'Cá hồi áp chảo', description: 'Ăn kèm khoai nghiền và rau xanh', price: 89000, icon: Icons.set_meal, color: Color(0xFFFFE2E2)),
  MealMenuItem(id: 'm5', name: 'Bún gà', description: 'Bún tươi, thịt gà và nước dùng', price: 42000, icon: Icons.ramen_dining, color: Color(0xFFE6F2FF)),
  MealMenuItem(id: 'm6', name: 'Cơm cá kho', description: 'Cá kho nhạt, cơm và canh rau', price: 50000, icon: Icons.lunch_dining, color: Color(0xFFF0E8FF)),
  MealMenuItem(id: 'm7', name: 'Súp bí đỏ', description: 'Súp bí đỏ kem tươi, khẩu phần nhỏ', price: 30000, icon: Icons.soup_kitchen, color: Color(0xFFFFEBD9)),
  MealMenuItem(id: 'm8', name: 'Salad ức gà', description: 'Ức gà, rau theo mùa và sốt nhẹ', price: 48000, icon: Icons.eco_outlined, color: Color(0xFFE3F4EB)),
];

class MealMenuScreen extends StatefulWidget {
  const MealMenuScreen({super.key, this.memberName = ''});

  final String memberName;

  @override
  State<MealMenuScreen> createState() => _MealMenuScreenState();
}

class _MealMenuScreenState extends State<MealMenuScreen> {
  final Map<String, int> _quantities = {};
  late final List<DateTime> _dates;
  late DateTime _selectedDate;
  String _selectedMeal = 'Trưa';

  int get _itemCount => _quantities.values.fold(0, (sum, quantity) => sum + quantity);
  int get _total => _menuItems.fold(0, (sum, item) => sum + item.price * (_quantities[item.id] ?? 0));

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _dates = List.generate(7, (index) => today.add(Duration(days: index)));
    _selectedDate = today;
  }

  void _changeQuantity(MealMenuItem item, int delta) {
    setState(() {
      final next = (_quantities[item.id] ?? 0) + delta;
      if (next <= 0) {
        _quantities.remove(item.id);
      } else {
        _quantities[item.id] = next;
      }
    });
  }

  void _openCart() {
    if (_itemCount == 0) return;
    final lines = _menuItems
        .where((item) => (_quantities[item.id] ?? 0) > 0)
        .map((item) => MealCartLine(item: item, quantity: _quantities[item.id]!))
        .toList(growable: false);
    context.push('/meal-cart', extra: MealCartPayload(
      recipientName: widget.memberName,
      date: _selectedDate,
      meal: _selectedMeal,
      lines: lines,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat('#,##0', 'vi_VN');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BlueAppBar(
        title: 'Thực đơn',
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Quay lại',
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE6F1FC),
                  foregroundColor: AppColors.primary,
                  child: Icon(Icons.person_outline),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Suất ăn dành cho', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text(widget.memberName.isEmpty ? 'Thành viên' : widget.memberName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 15, 16, 8),
            child: Text('Chọn ngày nhận', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
          SizedBox(
            height: 72,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _dates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final date = _dates[index];
                final selected = DateUtils.isSameDay(date, _selectedDate);
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _selectedDate = date),
                  child: Container(
                    width: 56,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE2E4E8)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_weekdayLabel(date.weekday), style: TextStyle(fontSize: 11, color: selected ? Colors.white70 : AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('${date.day}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: selected ? Colors.white : AppColors.textPrimary)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 15, 16, 8),
            child: Text('Chọn bữa ăn', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _mealOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 9),
              itemBuilder: (context, index) {
                final meal = _mealOptions[index];
                final selected = meal == _selectedMeal;
                return ChoiceChip(
                  label: Text(meal),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedMeal = meal),
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w700),
                  showCheckmark: false,
                  side: BorderSide(color: selected ? AppColors.primary : const Color(0xFFE1E3E7)),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text('Món ăn hôm nay', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _menuItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final quantity = _quantities[item.id] ?? 0;
                return _MealItemCard(
                  item: item,
                  quantity: quantity,
                  formattedPrice: '${money.format(item.price)}đ',
                  onDecrease: () => _changeQuantity(item, -1),
                  onIncrease: () => _changeQuantity(item, 1),
                );
              },
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
              onPressed: _itemCount == 0 ? null : _openCart,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_basket_outlined),
                  const SizedBox(width: 8),
                  Text('Xem giỏ ($_itemCount món) - ${money.format(_total)}đ',
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _weekdayLabel(int weekday) => switch (weekday) {
      DateTime.monday => 'T2',
      DateTime.tuesday => 'T3',
      DateTime.wednesday => 'T4',
      DateTime.thursday => 'T5',
      DateTime.friday => 'T6',
      DateTime.saturday => 'T7',
      _ => 'CN',
    };

class _MealItemCard extends StatelessWidget {
  const _MealItemCard({
    required this.item,
    required this.quantity,
    required this.formattedPrice,
    required this.onDecrease,
    required this.onIncrease,
  });

  final MealMenuItem item;
  final int quantity;
  final String formattedPrice;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(11),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(color: item.color, borderRadius: BorderRadius.circular(12)),
                child: Icon(item.icon, size: 38, color: AppColors.secondaryGreen),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.25)),
                    const SizedBox(height: 7),
                    Text(formattedPrice, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              _QuantityControl(quantity: quantity, onDecrease: onDecrease, onIncrease: onIncrease),
            ],
          ),
        ),
      );
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.quantity, required this.onDecrease, required this.onIncrease});
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(icon: Icons.remove, onPressed: quantity == 0 ? null : onDecrease),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          _QuantityButton(icon: Icons.add, onPressed: onIncrease, filled: true),
        ],
      );
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed, this.filled = false});
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 28,
        height: 28,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: onPressed,
          icon: Icon(icon, size: 17),
          style: IconButton.styleFrom(
            foregroundColor: filled ? Colors.white : AppColors.primary,
            backgroundColor: filled ? AppColors.primary : const Color(0xFFEAF2FB),
            disabledForegroundColor: AppColors.textSecondary.withOpacity(.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
}
