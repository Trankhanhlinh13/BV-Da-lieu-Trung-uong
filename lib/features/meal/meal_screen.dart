import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/blue_app_bar.dart';
import '../../core/widgets/empty_state.dart';
import '../../mock/mock_data.dart';
import '../../models/user_profile.dart';
import 'widgets/member_card.dart';

class MealMembersScreen extends StatefulWidget {
  const MealMembersScreen({super.key});

  @override
  State<MealMembersScreen> createState() => _MealMembersScreenState();
}

class _MealMembersScreenState extends State<MealMembersScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  List<UserProfile> get _filteredMembers => MockData.mealMembers
      .where((member) => member.name.toLowerCase().contains(_query.trim().toLowerCase()))
      .toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openMealMenu(UserProfile member) {
    context.push(Uri(
      path: '/meal-menu',
      queryParameters: {'name': member.name},
    ).toString());
  }

  @override
  Widget build(BuildContext context) {
    final members = _filteredMembers;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BlueAppBar(
        title: 'Đặt suất ăn cho',
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Tìm thành viên',
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE1E3E7)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE1E3E7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            Expanded(
              child: members.isEmpty
                  ? const EmptyState(
                      icon: Icons.person_search_outlined,
                      text: 'Không tìm thấy thành viên',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                      itemCount: members.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) => MemberCard(
                        member: members[index],
                        onTap: () => _openMealMenu(members[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

