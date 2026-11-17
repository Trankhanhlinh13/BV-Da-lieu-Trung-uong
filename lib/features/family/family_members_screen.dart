import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/family_members_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/blue_app_bar.dart';
import '../../models/family_member.dart';
import '../../models/user_profile.dart';
import '../meal/widgets/member_card.dart';

class FamilyMembersScreen extends ConsumerWidget {
  const FamilyMembersScreen({super.key});

  UserProfile _asUserProfile(FamilyMember member) => UserProfile(
        name: member.name,
        phone: member.phone,
        birthDate: member.birthDate,
        gender: member.gender,
        isOwner: member.isOwner,
      );

  Future<void> _deleteMember(
    BuildContext context,
    WidgetRef ref,
    FamilyMember member,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa thành viên'),
        content: Text('Bạn có chắc muốn xóa ${member.name} khỏi danh sách?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(familyMembersProvider.notifier).removeMember(member.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(familyMembersProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BlueAppBar(
        title: 'Thành viên gia đình',
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: () => context.go('/profile'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: members.isEmpty
          ? const Center(child: Text('Chưa có thành viên'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: members.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final member = members[index];
                return MemberCard(
                  member: _asUserProfile(member),
                  showChevron: false,
                  trailing: member.isOwner
                      ? const SizedBox(width: 16)
                      : PopupMenuButton<String>(
                          tooltip: 'Tùy chọn thành viên',
                          onSelected: (action) {
                            if (action == 'edit') {
                              context.push('/family/edit/${member.id}');
                            } else if (action == 'delete') {
                              _deleteMember(context, ref, member);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Sửa')),
                            PopupMenuItem(value: 'delete', child: Text('Xóa')),
                          ],
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(Icons.more_vert,
                                color: AppColors.textSecondary),
                          ),
                        ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.sizeOf(context).width - 32,
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/family/add'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text(
            'Thêm thành viên',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
