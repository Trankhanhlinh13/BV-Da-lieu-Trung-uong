import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/blue_app_bar.dart';
import '../../core/widgets/primary_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _formIsValid = false;

  bool get _hasMinLength => _newPasswordController.text.length >= 8;
  bool get _hasLetter => RegExp(r'[A-Za-z]').hasMatch(_newPasswordController.text);
  bool get _hasNumber => RegExp(r'\d').hasMatch(_newPasswordController.text);
  bool get _newPasswordValid => _hasMinLength && _hasLetter && _hasNumber;
  bool get _passwordsMatch =>
      _newPasswordController.text == _confirmPasswordController.text;
  bool get _isDifferentFromCurrent =>
      _newPasswordController.text != _currentPasswordController.text;

  bool get _allFieldsValid =>
      _currentPasswordController.text.isNotEmpty &&
      _newPasswordValid &&
      _isDifferentFromCurrent &&
      _confirmPasswordController.text.isNotEmpty &&
      _passwordsMatch;

  void _updateForm(String _) {
    final valid = _allFieldsValid;
    setState(() => _formIsValid = valid);
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || !_allFieldsValid) return;
    FocusManager.instance.primaryFocus?.unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đổi mật khẩu thành công'),
        backgroundColor: AppColors.secondaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: BlueAppBar(
          title: 'Đổi mật khẩu',
          leading: IconButton(
            tooltip: 'Quay lại',
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  children: [
                    AppTextField(
                      label: 'Mật khẩu hiện tại',
                      hint: 'Nhập mật khẩu hiện tại',
                      controller: _currentPasswordController,
                      onChanged: _updateForm,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.lock_outline,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Vui lòng nhập mật khẩu hiện tại'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Mật khẩu mới',
                      hint: 'Nhập mật khẩu mới',
                      controller: _newPasswordController,
                      onChanged: _updateForm,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.lock_reset_outlined,
                      validator: (value) {
                        if (!_newPasswordValid) {
                          return 'Mật khẩu cần đủ 8 ký tự, có chữ và số';
                        }
                        if (!_isDifferentFromCurrent) {
                          return 'Mật khẩu mới không được trùng mật khẩu hiện tại';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _PasswordRequirement(
                      text: 'Ít nhất 8 ký tự',
                      isMet: _hasMinLength,
                    ),
                    const SizedBox(height: 6),
                    _PasswordRequirement(
                      text: 'Có ít nhất một chữ cái',
                      isMet: _hasLetter,
                    ),
                    const SizedBox(height: 6),
                    _PasswordRequirement(
                      text: 'Có ít nhất một chữ số',
                      isMet: _hasNumber,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Nhập lại mật khẩu mới',
                      hint: 'Nhập lại mật khẩu mới',
                      controller: _confirmPasswordController,
                      onChanged: _updateForm,
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập lại mật khẩu mới';
                        }
                        if (!_passwordsMatch) {
                          return 'Mật khẩu nhập lại không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'Lưu thay đổi',
                      onPressed: _saveChanges,
                      enabled: _formIsValid,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class _PasswordRequirement extends StatelessWidget {
  const _PasswordRequirement({required this.text, required this.isMet});
  final String text;
  final bool isMet;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 17,
            color: isMet ? AppColors.secondaryGreen : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? AppColors.secondaryGreen : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      );
}
