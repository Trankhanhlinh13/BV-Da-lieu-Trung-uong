import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/state/family_members_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/blue_app_bar.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/family_member.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({super.key, this.member});

  final FamilyMember? member;

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  static const _relationships = [
    'Bố',
    'Mẹ',
    'Vợ/Chồng',
    'Con',
    'Anh/Chị/Em',
    'Khác',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _phoneController;
  late final TextEditingController _identityController;
  DateTime? _birthDate;
  String? _gender;
  String? _relationship;
  bool _formIsValid = false;

  bool get _phoneIsValid {
    final phone = _phoneController.text.trim();
    return phone.isEmpty || RegExp(r'^0\d{9}$').hasMatch(phone);
  }

  bool get _allFieldsValid =>
      _nameController.text.trim().isNotEmpty &&
      _birthDate != null &&
      _gender != null &&
      _phoneIsValid &&
      _relationship != null;

  @override
  void initState() {
    super.initState();
    final member = widget.member;
    _nameController = TextEditingController(text: member?.name ?? '');
    _birthDate = member?.birthDate;
    _birthDateController = TextEditingController(
      text: member == null
          ? ''
          : DateFormat('dd/MM/yyyy').format(member.birthDate),
    );
    _phoneController = TextEditingController(text: member?.phone ?? '');
    _identityController =
        TextEditingController(text: member?.identityNumber ?? '');
    _gender = member?.gender;
    _relationship = member?.relationship == 'Người thân'
        ? 'Khác'
        : member?.relationship;
    _formIsValid = _allFieldsValid;
  }

  void _updateForm([String? _]) {
    final isValid = _allFieldsValid;
    setState(() => _formIsValid = isValid);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _birthDate = picked;
      _birthDateController.text = DateFormat('dd/MM/yyyy').format(picked);
    });
    _updateForm();
  }

  void _save() {
    if (!_formKey.currentState!.validate() || !_allFieldsValid) return;
    final currentMember = widget.member;
    final savedMember = FamilyMember(
      id: currentMember?.id ?? 'family-${DateTime.now().microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      birthDate: _birthDate!,
      gender: _gender!,
      relationship: _relationship!,
      identityNumber: _identityController.text.trim(),
      isOwner: false,
    );
    final controller = ref.read(familyMembersProvider.notifier);
    if (currentMember == null) {
      controller.addMember(savedMember);
    } else {
      controller.updateMember(savedMember);
    }
    context.pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _identityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: BlueAppBar(
          title: widget.member == null ? 'Thêm thành viên' : 'Sửa thành viên',
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
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  children: [
                    AppTextField(
                      label: 'Họ tên*',
                      hint: 'Nhập họ tên',
                      controller: _nameController,
                      onChanged: _updateForm,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.person_outline,
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập họ tên'
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
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      children: ['Nam', 'Nữ', 'Khác'].map((gender) {
                        final selected = _gender == gender;
                        return ChoiceChip(
                          label: Text(gender),
                          selected: selected,
                          selectedColor: AppColors.primary.withOpacity(0.12),
                          side: BorderSide(
                            color: selected
                                ? AppColors.primary
                                : const Color(0xFFE1E3E7),
                          ),
                          labelStyle: TextStyle(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                          onSelected: (_) {
                            setState(() => _gender = gender);
                            _updateForm();
                          },
                        );
                      }).toList(),
                    ),
                    if (_gender == null)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Vui lòng chọn giới tính',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 18),
                    AppTextField(
                      label: 'Số điện thoại',
                      hint: 'Nhập số điện thoại',
                      controller: _phoneController,
                      onChanged: _updateForm,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      maxLength: 10,
                      prefixIcon: Icons.phone_outlined,
                      validator: (value) {
                        final phone = value?.trim() ?? '';
                        if (phone.isNotEmpty &&
                            !RegExp(r'^0\d{9}$').hasMatch(phone)) {
                          return 'Số điện thoại gồm 10 số và bắt đầu bằng 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    const _RequiredLabel('Quan hệ'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _relationship,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        hintText: 'Chọn quan hệ',
                        prefixIcon: Icon(Icons.family_restroom_outlined),
                      ),
                      items: _relationships
                          .map((relation) => DropdownMenuItem(
                                value: relation,
                                child: Text(relation),
                              ))
                          .toList(),
                      validator: (value) => value == null
                          ? 'Vui lòng chọn quan hệ'
                          : null,
                      onChanged: (value) {
                        setState(() => _relationship = value);
                        _updateForm();
                      },
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      label: 'Số CCCD hoặc Mã BHYT',
                      hint: 'Nhập số CCCD hoặc mã BHYT',
                      controller: _identityController,
                      onChanged: _updateForm,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 26),
                    PrimaryButton(
                      label: 'Lưu',
                      onPressed: _save,
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
