import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/state/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../mock/mock_data.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/blue_app_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/otp_input.dart';
import 'package:intl/intl.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const _demoPassword = '123456';
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isFormValid = false;
  String? _loginError;

  bool get _phoneIsValid => RegExp(r'^0\d{9}$').hasMatch(_phoneController.text.trim());
  bool get _passwordIsValid => _passwordController.text.isNotEmpty;

  void _updateForm(String _) {
    final valid = _phoneIsValid && _passwordIsValid;
    if (valid != _isFormValid || _loginError != null) {
      setState(() {
        _isFormValid = valid;
        _loginError = null;
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
      _loginError = null;
    });

    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final credentialsAreCorrect =
        _phoneController.text.trim() == MockData.user.phone &&
        _passwordController.text == _demoPassword;
    if (!credentialsAreCorrect) {
      setState(() {
        _isLoading = false;
        _loginError = 'Số điện thoại hoặc mật khẩu không đúng';
      });
      return;
    }

    ref.read(authProvider.notifier).login();
    context.go('/home');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 56),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 112,
                            height: 112,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const _LoginLogoFallback(),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'BV Da liễu Trung ương',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Đăng nhập để đặt lịch khám',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const _FieldLabel('Số điện thoại'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          onChanged: _updateForm,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          maxLength: 10,
                          validator: (value) =>
                              RegExp(r'^0\d{9}$').hasMatch(value?.trim() ?? '')
                                  ? null
                                  : 'Nhập số điện thoại gồm 10 số, bắt đầu bằng 0',
                          decoration: const InputDecoration(
                            hintText: 'Nhập số điện thoại',
                            prefixIcon: Icon(Icons.phone_outlined),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('Mật khẩu'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          onChanged: _updateForm,
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            if (_isFormValid && !_isLoading) _login();
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Vui lòng nhập mật khẩu'
                              : null,
                          decoration: InputDecoration(
                            hintText: 'Nhập mật khẩu',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _isPasswordVisible
                                  ? 'Ẩn mật khẩu'
                                  : 'Hiện mật khẩu',
                              onPressed: () => setState(() =>
                                  _isPasswordVisible = !_isPasswordVisible),
                              icon: Icon(_isPasswordVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.go('/forgot-password'),
                            child: const Text(
                              'Quên mật khẩu?',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ),
                        if (_loginError != null) ...[
                          Text(
                            _loginError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.danger,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        PrimaryButton(
                          label: 'Đăng nhập',
                          onPressed: _login,
                          enabled: _isFormValid,
                          loading: _isLoading,
                        ),
                        const SizedBox(height: 18),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                'hoặc',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Đăng nhập bằng FaceID chưa khả dụng trong bản demo.',
                                      ),
                                    ),
                                  ),
                          icon: const Icon(Icons.face_retouching_natural),
                          label: const Text('Đăng nhập bằng FaceID'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              const Text('Chưa có tài khoản? '),
                              GestureDetector(
                                onTap: () => context.go('/register'),
                                child: const Text(
                                  'Đăng ký',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(color: AppColors.textSecondary),
                              children: [
                                TextSpan(text: 'Hotline hỗ trợ: '),
                                TextSpan(
                                  text: '1900 6422',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      );
}

class _LoginLogoFallback extends StatelessWidget {
  const _LoginLogoFallback();

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 112,
        height: 112,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.menu_book_rounded,
                size: 82, color: AppColors.primary),
            Positioned(
              top: 4,
              right: 7,
              child: Container(
                width: 29,
                height: 29,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
      );
}
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _identityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _birthDate;
  String? _gender;
  bool _acceptedTerms = false;
  bool _formIsValid = false;

  bool get _passwordValid =>
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$')
          .hasMatch(_passwordController.text);

  bool _allValuesAreValid() {
    final phoneValid = RegExp(r'^0\d{9}$')
        .hasMatch(_phoneController.text.trim());
    final identity = _identityController.text.trim();
    final identityValid =
        identity.isEmpty || RegExp(r'^(\d{9}|\d{12})$').hasMatch(identity);
    return _nameController.text.trim().isNotEmpty &&
        _birthDate != null &&
        _gender != null &&
        phoneValid &&
        identityValid &&
        _passwordValid &&
        _confirmPasswordController.text == _passwordController.text &&
        _acceptedTerms;
  }

  void _refreshValidity([String? _]) {
    final valid = _allValuesAreValid();
    if (valid != _formIsValid) {
      setState(() => _formIsValid = valid);
    } else {
      setState(() {});
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
      cancelText: 'HỦY',
      confirmText: 'CHỌN',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _birthDate = picked;
      _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
    });
    _refreshValidity();
  }

  void _continueToOtp() {
    if (!_formKey.currentState!.validate() || !_allValuesAreValid()) {
      _refreshValidity();
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    final location = Uri(
      path: '/otp',
      queryParameters: {
        'phone': _phoneController.text.trim(),
        'purpose': 'register',
      },
    ).toString();
    context.go(location);
  }

  void _showLegalSheet(String title, String body) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.68,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        )),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      body,
                      style: const TextStyle(height: 1.55),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int get _passwordStrength {
    final password = _passwordController.text;
    if (password.length >= 12 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 3;
    }
    if (password.length >= 8 &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password)) {
      return 2;
    }
    return 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _identityController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strength = _passwordStrength;
    final strengthLabel = switch (strength) {
      3 => 'Mạnh',
      2 => 'Trung bình',
      _ => 'Yếu',
    };
    final strengthColor = switch (strength) {
      3 => AppColors.secondaryGreen,
      2 => const Color(0xFFE8A323),
      _ => AppColors.danger,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BlueAppBar(
        title: 'Đăng ký tài khoản',
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: () => context.go('/login'),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  AppTextField(
                    label: 'Họ và tên*',
                    hint: 'Nhập họ và tên',
                    controller: _nameController,
                    onChanged: _refreshValidity,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.person_outline,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Vui lòng nhập họ và tên'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Ngày sinh*',
                    hint: 'dd/MM/yyyy',
                    controller: _birthDateController,
                    readOnly: true,
                    onTap: _pickBirthDate,
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                    validator: (_) => _birthDate == null
                        ? 'Vui lòng chọn ngày sinh'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  const _RequiredLabel('Giới tính'),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 10,
                    children: ['Nam', 'Nữ', 'Khác'].map((gender) {
                      final selected = _gender == gender;
                      return ChoiceChip(
                        label: Text(gender),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _gender = gender);
                          _refreshValidity();
                        },
                        selectedColor: AppColors.primary.withOpacity(0.12),
                        side: BorderSide(
                          color: selected
                              ? AppColors.primary
                              : const Color(0xFFE2E4E8),
                        ),
                        labelStyle: TextStyle(
                          color: selected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  if (_gender == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        'Vui lòng chọn giới tính',
                        style: TextStyle(color: AppColors.danger, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Số điện thoại*',
                    hint: 'Nhập số điện thoại',
                    controller: _phoneController,
                    onChanged: _refreshValidity,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    maxLength: 10,
                    prefixIcon: Icons.phone_outlined,
                    validator: (value) =>
                        RegExp(r'^0\d{9}$').hasMatch(value?.trim() ?? '')
                            ? null
                            : 'Số điện thoại phải gồm 10 số và bắt đầu bằng 0',
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Số CCCD/CMND',
                    hint: 'Nhập 9 hoặc 12 chữ số',
                    controller: _identityController,
                    onChanged: _refreshValidity,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    maxLength: 12,
                    prefixIcon: Icons.badge_outlined,
                    validator: (value) {
                      final identity = value?.trim() ?? '';
                      if (identity.isNotEmpty &&
                          !RegExp(r'^(\d{9}|\d{12})$').hasMatch(identity)) {
                        return 'CCCD/CMND phải gồm 9 hoặc 12 chữ số';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Mật khẩu*',
                    hint: 'Tối thiểu 8 ký tự, gồm chữ và số',
                    controller: _passwordController,
                    onChanged: _refreshValidity,
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.lock_outline,
                    validator: (value) =>
                        RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$')
                                .hasMatch(value ?? '')
                            ? null
                            : 'Mật khẩu cần ít nhất 8 ký tự, gồm chữ và số',
                  ),
                  const SizedBox(height: 9),
                  _PasswordStrengthIndicator(
                    strength: strength,
                    label: strengthLabel,
                    color: strengthColor,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Nhập lại mật khẩu*',
                    hint: 'Nhập lại mật khẩu',
                    controller: _confirmPasswordController,
                    onChanged: _refreshValidity,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.lock_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập lại mật khẩu';
                      }
                      if (value != _passwordController.text) {
                        return 'Mật khẩu nhập lại không khớp';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) {
                            setState(() => _acceptedTerms = value ?? false);
                            _refreshValidity();
                          },
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Wrap(
                          children: [
                            const Text('Tôi đồng ý với '),
                            _LegalLink(
                              text: 'Điều khoản sử dụng',
                              onTap: () => _showLegalSheet(
                                'Điều khoản sử dụng',
                                'Đây là nội dung điều khoản sử dụng minh họa cho ứng dụng đặt lịch khám. Khi đăng ký, bạn đồng ý cung cấp thông tin chính xác và sử dụng tài khoản cho mục đích chăm sóc sức khỏe. Bạn có thể liên hệ bệnh viện nếu cần hỗ trợ về tài khoản.',
                              ),
                            ),
                            const Text(' và '),
                            _LegalLink(
                              text: 'Chính sách bảo mật',
                              onTap: () => _showLegalSheet(
                                'Chính sách bảo mật',
                                'Đây là nội dung chính sách bảo mật minh họa. Thông tin cá nhân và thông tin sức khỏe được sử dụng để hỗ trợ các chức năng trong ứng dụng. Bản demo này chỉ lưu dữ liệu trong bộ nhớ và không gửi thông tin đến máy chủ.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: 'Tiếp tục',
                    onPressed: _continueToOtp,
                    enabled: _formIsValid,
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        const Text('Đã có tài khoản? '),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text(
                            'Đăng nhập',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text.rich(
        TextSpan(
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          children: [
            TextSpan(text: text),
            const TextSpan(
              text: '*',
              style: TextStyle(color: AppColors.danger),
            ),
          ],
        ),
      );
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.primary,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _PasswordStrengthIndicator extends StatelessWidget {
  const _PasswordStrengthIndicator({
    required this.strength,
    required this.label,
    required this.color,
  });
  final int strength;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  height: 5,
                  margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: index < strength
                        ? color
                        : const Color(0xFFE7E8EB),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Độ mạnh mật khẩu: $label',
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      );
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, this.phone, this.purpose});

  final String? phone;
  final String? purpose;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  Timer? _timer;
  int _secondsRemaining = 59;
  String _code = '';
  bool _hasError = false;
  int _errorNonce = 0;
  Key _otpInputKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        setState(() => _secondsRemaining = 0);
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String get _maskedPhone {
    final value = widget.phone?.trim() ?? '';
    if (value.isEmpty) return 'số điện thoại của bạn';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length <= 6) return '*' * digits.length;
    final hiddenCount = digits.length - 6;
    return '${digits.substring(0, 3)}${'*' * hiddenCount}${digits.substring(digits.length - 3)}';
  }

  String get _countdownLabel {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _resendCode() {
    setState(() {
      _secondsRemaining = 59;
      _code = '';
      _hasError = false;
      _otpInputKey = UniqueKey();
    });
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã gửi lại mã OTP (bản demo).')),
    );
  }

  Future<void> _confirmCode() async {
    if (_code.length != 6) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (_code != '123456') {
      HapticFeedback.lightImpact();
      setState(() {
        _hasError = true;
        _errorNonce++;
      });
      return;
    }

    if (widget.purpose == 'register') {
      final continueToLogin = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline,
              color: AppColors.secondaryGreen, size: 46),
          title: const Text('Xác thực thành công'),
          content: const Text('Số điện thoại của bạn đã được xác thực.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Tiếp tục'),
            ),
          ],
        ),
      );
      if (continueToLogin == true && mounted) context.go('/login');
      return;
    }

    if (mounted) context.go('/reset-password');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRegistration = widget.purpose == 'register';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BlueAppBar(
        title: 'Xác thực số điện thoại',
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: () => context.go(
            isRegistration ? '/register' : '/forgot-password',
          ),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
              children: [
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE7F1FC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      color: AppColors.primary,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  'Nhập mã xác thực',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Mã gồm 6 chữ số đã được gửi tới $_maskedPhone',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 32),
                OtpInput(
                  key: _otpInputKey,
                  length: 6,
                  hasError: _hasError,
                  errorNonce: _errorNonce,
                  onChanged: (value) => setState(() {
                    _code = value;
                    if (_hasError) _hasError = false;
                  }),
                ),
                if (_hasError) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Mã OTP không đúng',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Center(
                  child: _secondsRemaining > 0
                      ? Text(
                          'Gửi lại mã sau $_countdownLabel',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        )
                      : TextButton(
                          onPressed: _resendCode,
                          child: const Text(
                            'Gửi lại mã',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Xác nhận',
                  onPressed: _confirmCode,
                  enabled: _code.length == 6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _phoneIsValid = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (!_formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    context.go(Uri(
      path: '/otp',
      queryParameters: {
        'phone': _phoneController.text.trim(),
        'purpose': 'reset',
      },
    ).toString());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: BlueAppBar(
          title: 'Quên mật khẩu',
          leading: IconButton(
            tooltip: 'Quay lại',
            onPressed: () => context.go('/login'),
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
                  padding: const EdgeInsets.fromLTRB(24, 42, 24, 32),
                  children: [
                    Center(
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE7F1FC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.primary,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Khôi phục mật khẩu',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Nhập số điện thoại đã đăng ký, chúng tôi sẽ gửi mã OTP',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 30),
                    AppTextField(
                      label: 'Số điện thoại',
                      hint: 'Nhập số điện thoại',
                      controller: _phoneController,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      maxLength: 10,
                      onChanged: (value) => setState(() => _phoneIsValid =
                          RegExp(r'^0\d{9}$').hasMatch(value.trim())),
                      validator: (value) =>
                          RegExp(r'^0\d{9}$').hasMatch(value?.trim() ?? '')
                              ? null
                              : 'Nhập số điện thoại gồm 10 số, bắt đầu bằng 0',
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Gửi mã OTP',
                      onPressed: _sendOtp,
                      enabled: _phoneIsValid,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _formIsValid = false;

  bool get _passwordValid =>
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$')
          .hasMatch(_passwordController.text);

  bool get _allFieldsValid =>
      _passwordValid &&
      _confirmPasswordController.text == _passwordController.text;

  int get _passwordStrength {
    final password = _passwordController.text;
    if (password.length >= 12 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      return 3;
    }
    if (password.length >= 8 &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password)) {
      return 2;
    }
    return 1;
  }

  void _onPasswordChanged(String _) {
    final valid = _allFieldsValid;
    setState(() => _formIsValid = valid);
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate() || !_allFieldsValid) return;
    FocusManager.instance.primaryFocus?.unfocus();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle_outline,
          color: AppColors.secondaryGreen,
          size: 46,
        ),
        title: const Text('Đặt lại mật khẩu thành công'),
        content: const Text('Bạn có thể đăng nhập bằng mật khẩu mới.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
    if (mounted) context.go('/login');
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strength = _passwordStrength;
    final strengthLabel = switch (strength) {
      3 => 'Mạnh',
      2 => 'Trung bình',
      _ => 'Yếu',
    };
    final strengthColor = switch (strength) {
      3 => AppColors.secondaryGreen,
      2 => const Color(0xFFE8A323),
      _ => AppColors.danger,
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BlueAppBar(
        title: 'Đặt lại mật khẩu',
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: () => context.go('/forgot-password'),
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
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 32),
                children: [
                  AppTextField(
                    label: 'Mật khẩu mới',
                    hint: 'Tối thiểu 8 ký tự, gồm chữ và số',
                    controller: _passwordController,
                    onChanged: _onPasswordChanged,
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.lock_outline,
                    validator: (value) =>
                        RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$')
                                .hasMatch(value ?? '')
                            ? null
                            : 'Mật khẩu cần ít nhất 8 ký tự, gồm chữ và số',
                  ),
                  const SizedBox(height: 9),
                  _PasswordStrengthIndicator(
                    strength: strength,
                    label: strengthLabel,
                    color: strengthColor,
                  ),
                  const SizedBox(height: 22),
                  AppTextField(
                    label: 'Nhập lại mật khẩu mới',
                    hint: 'Nhập lại mật khẩu mới',
                    controller: _confirmPasswordController,
                    onChanged: _onPasswordChanged,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.lock_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập lại mật khẩu mới';
                      }
                      if (value != _passwordController.text) {
                        return 'Mật khẩu nhập lại không khớp';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 26),
                  PrimaryButton(
                    label: 'Cập nhật mật khẩu',
                    onPressed: _updatePassword,
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
}
