import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../mock/mock_data.dart';
import '../../models/health_record.dart';
import '../../models/user_profile.dart';

class HealthRecordScreen extends StatelessWidget {
  const HealthRecordScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Hồ sơ sức khoẻ'),
            centerTitle: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              tooltip: 'Quay lại',
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.arrow_back),
            ),
            actions: [
              IconButton(
                tooltip: 'Trợ giúp',
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Hồ sơ sức khoẻ'),
                    content: const Text(
                      'Xem các lượt khám đã lưu trong hồ sơ của bạn hoặc thành viên gia đình.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Đã hiểu'),
                      ),
                    ],
                  ),
                ),
                icon: const CircleAvatar(
                  radius: 13,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.help_outline,
                      color: AppColors.primary, size: 19),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Material(
                color: Colors.white,
                child: TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: 15),
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2.5,
                  tabs: const [
                    Tab(text: 'Hồ sơ sức khoẻ'),
                    Tab(text: 'Quản lý liên kết'),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    _HealthProfileTab(),
                    _LinkedProfilesPlaceholder(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _HealthProfileTab extends StatefulWidget {
  const _HealthProfileTab();

  @override
  State<_HealthProfileTab> createState() => _HealthProfileTabState();
}

class _HealthProfileTabState extends State<_HealthProfileTab> {
  final _memberScrollController = ScrollController();
  late final List<UserProfile> _members;
  int _selectedMemberIndex = 0;

  UserProfile get _selectedMember => _members[_selectedMemberIndex];

  @override
  void initState() {
    super.initState();
    _members = [MockData.user, ...MockData.familyMembers];
  }

  @override
  void dispose() {
    _memberScrollController.dispose();
    super.dispose();
  }

  void _selectMember(int index) {
    if (index < 0 || index >= _members.length) return;
    setState(() => _selectedMemberIndex = index);
    if (_memberScrollController.hasClients) {
      final target = (index * 126.0).clamp(
        0.0,
        _memberScrollController.position.maxScrollExtent,
      ).toDouble();
      _memberScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Map<String, List<HealthRecord>> _groupRecordsByMonth() {
    final groups = <String, List<HealthRecord>>{};
    for (final record in MockData.records) {
      final date = DateFormat('dd/MM/yyyy').parseStrict(record.date);
      final month = DateFormat('MM/yyyy').format(date);
      groups.putIfAbsent(month, () => []).add(record);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupRecordsByMonth();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _MemberStrip(
            members: _members,
            selectedIndex: _selectedMemberIndex,
            scrollController: _memberScrollController,
            onSelect: _selectMember,
          ),
        ),
        SliverToBoxAdapter(
          child: _ProfileSummary(profile: _selectedMember),
        ),
        for (final entry in groups.entries) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Tháng ${entry.key}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _HealthVisitCard(
                record: entry.value[index],
                memberName: _selectedMember.name,
              ),
              childCount: entry.value.length,
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

class _MemberStrip extends StatelessWidget {
  const _MemberStrip({
    required this.members,
    required this.selectedIndex,
    required this.scrollController,
    required this.onSelect,
  });

  final List<UserProfile> members;
  final int selectedIndex;
  final ScrollController scrollController;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => Container(
        color: const Color(0xFFF4F4F6),
        padding: const EdgeInsets.only(top: 14, bottom: 0),
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Thành viên trước',
                    onPressed: () => onSelect(selectedIndex - 1),
                    icon: const Icon(Icons.chevron_left, size: 30),
                    color: AppColors.textSecondary,
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: members.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) => _MemberAvatar(
                        member: members[index],
                        isSelected: index == selectedIndex,
                        onTap: () => onSelect(index),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Thành viên tiếp theo',
                    onPressed: () => onSelect(selectedIndex + 1),
                    icon: const Icon(Icons.chevron_right, size: 30),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.member,
    required this.isSelected,
    required this.onTap,
  });

  final UserProfile member;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 106,
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Container(
                width: 86,
                height: 86,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : const Color(0xFFE0E2E5),
                    width: isSelected ? 4 : 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    member.avatarAsset ?? 'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const _BookCrossLogo(),
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                member.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              if (isSelected)
                CustomPaint(
                  size: const Size(28, 12),
                  painter: _SelectionPointerPainter(),
                )
              else
                const SizedBox(height: 12),
            ],
          ),
        ),
      );
}

class _BookCrossLogo extends StatelessWidget {
  const _BookCrossLogo();

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.menu_book_rounded,
              size: 48, color: AppColors.primary),
          Positioned(
            right: 10,
            top: 13,
            child: Container(
              width: 15,
              height: 15,
              color: Colors.white,
              child: const Icon(Icons.add, color: AppColors.danger, size: 16),
            ),
          ),
        ],
      );
}

class _SelectionPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.profile});

  final UserProfile profile;

  int _age(DateTime birthDate) {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD5D8DD)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: CustomPaint(
                painter: _QrPlaceholderPainter(seed: profile.phone),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(profile.birthDate)} (${_age(profile.birthDate)} tuổi)',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _QrPlaceholderPainter extends CustomPainter {
  const _QrPlaceholderPainter({required this.seed});

  final String seed;
  static const _modules = 25;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _modules;
    final black = Paint()..color = const Color(0xFF111111);
    final white = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, white);

    final seedValue = seed.codeUnits.fold<int>(0, (value, item) => value + item);
    for (var y = 0; y < _modules; y++) {
      for (var x = 0; x < _modules; x++) {
        if (_isInFinder(x, y)) continue;
        final bit = (x * 17 + y * 13 + x * y + seedValue) % 7 < 3;
        if (bit) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell, cell),
            black,
          );
        }
      }
    }
    _drawFinder(canvas, cell, 0, 0, black, white);
    _drawFinder(canvas, cell, _modules - 7, 0, black, white);
    _drawFinder(canvas, cell, 0, _modules - 7, black, white);
  }

  bool _isInFinder(int x, int y) =>
      (x < 8 && y < 8) ||
      (x >= _modules - 8 && y < 8) ||
      (x < 8 && y >= _modules - 8);

  void _drawFinder(
    Canvas canvas,
    double cell,
    int startX,
    int startY,
    Paint black,
    Paint white,
  ) {
    canvas.drawRect(
      Rect.fromLTWH(startX * cell, startY * cell, 7 * cell, 7 * cell),
      black,
    );
    canvas.drawRect(
      Rect.fromLTWH((startX + 1) * cell, (startY + 1) * cell, 5 * cell, 5 * cell),
      white,
    );
    canvas.drawRect(
      Rect.fromLTWH((startX + 2) * cell, (startY + 2) * cell, 3 * cell, 3 * cell),
      black,
    );
  }

  @override
  bool shouldRepaint(covariant _QrPlaceholderPainter oldDelegate) =>
      oldDelegate.seed != seed;
}

class _HealthVisitCard extends StatelessWidget {
  const _HealthVisitCard({required this.record, required this.memberName});

  final HealthRecord record;
  final String memberName;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy').parseStrict(record.date);
    return GestureDetector(
      onTap: () => context.push('/health-record/detail', extra: record),
      child: Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x17000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 72,
              child: Column(
                children: [
                  Text(
                    date.day.toString(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 48,
                      height: 0.95,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.month.toString().padLeft(2, '0')}/${date.year}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 104,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: const Color(0xFFD9DDE3),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Text(
                      memberName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'BV Da liễu Trung ương',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        'HS: ${record.recordCode}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.statusOutpatient,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          record.description,
                          style: const TextStyle(
                            color: AppColors.secondaryGreen,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _LinkedProfilesPlaceholder extends StatelessWidget {
  const _LinkedProfilesPlaceholder();

  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_add_outlined,
                size: 52, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text(
              'Quản lý liên kết',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
}
