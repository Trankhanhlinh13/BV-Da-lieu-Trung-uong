import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/state/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/blue_app_bar.dart';
import '../../mock/mock_data.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _faceIdEnabled = false;
  String _language = 'Tiếng Việt';

  Future<void> _chooseLanguage() async {
    final language = await showModalBottomSheet<String>(
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
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Chọn ngôn ngữ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            for (final language in const ['Tiếng Việt', 'English'])
              RadioListTile<String>(
                value: language,
                groupValue: _language,
                activeColor: AppColors.primary,
                title: Text(language),
                onChanged: (value) => Navigator.of(context).pop(value),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
    if (language != null && mounted) setState(() => _language = language);
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Ở lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (shouldLogout == true && mounted) {
      ref.read(authProvider.notifier).logout();
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = MockData.user;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: const BlueAppBar(title: 'Cá nhân'),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
            child: Row(
              children: [
                Container(
                  width: 92,
                  height: 92,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFBFC9D5)),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      user.avatarAsset ?? 'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.menu_book_rounded,
                              size: 52, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.phone,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Tiện ích',
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _UtilityItem(
                      icon: Icons.groups_rounded,
                      label: 'Thành viên\ngia đình',
                      onTap: () => context.go('/family'),
                    ),
                  ),
                  Expanded(
                    child: _UtilityItem(
                      icon: Icons.assignment_rounded,
                      label: 'Hồ sơ\nsức khoẻ',
                      onTap: () => context.go('/health-record'),
                    ),
                  ),
                  Expanded(
                    child: _UtilityItem(
                      icon: Icons.event_available_rounded,
                      label: 'Lịch sử\nđặt khám',
                      onTap: () => context.go('/appointments'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Cài đặt',
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Đổi mật khẩu',
                  onTap: () => context.push('/change-password'),
                ),
                const Divider(height: 1, indent: 76, endIndent: 16),
                _SettingsTile(
                  icon: Icons.face_retouching_natural,
                  title: 'Đăng nhập FaceID',
                  trailing: Switch.adaptive(
                    value: _faceIdEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (value) =>
                        setState(() => _faceIdEnabled = value),
                  ),
                ),
                const Divider(height: 1, indent: 76, endIndent: 16),
                _SettingsTile(
                  icon: Icons.language,
                  title: 'Ngôn ngữ/ Language',
                  subtitle: _language,
                  onTap: _chooseLanguage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            title: 'Khác',
            child: _SettingsTile(
              icon: Icons.star_rounded,
              title: 'Về BV Da liễu Trung ương',
              onTap: () => context.go('/about'),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            color: Colors.white,
            child: _SettingsTile(
              icon: Icons.logout,
              title: 'Đăng xuất',
              onTap: _confirmLogout,
              iconColor: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.phone,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Text('Hotline: '),
                    Text(
                      '1900 6422',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Phiên bản: 91.0.0 ',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    InkWell(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bạn đang dùng phiên bản mới nhất (demo).'),
                        ),
                      ),
                      child: const Text(
                        'Cập nhật',
                        style: TextStyle(
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                          fontStyle: FontStyle.italic,
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
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.white,
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      );
}

class _UtilityItem extends StatelessWidget {
  const _UtilityItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 42),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor = AppColors.textSecondary,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        minVerticalPadding: 10,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F1F3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 25),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
        trailing: trailing ??
            (onTap == null
                ? null
                : const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary, size: 26)),
      );
}
