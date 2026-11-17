import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../mock/mock_data.dart';
import '../../models/booking_draft.dart';
import '../../models/user_profile.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({
    super.key,
    this.patient = 'owner',
    this.selectMember = false,
    this.initialDepartment,
    this.initialDoctor,
    this.initialTime,
    this.initialDate,
  });

  final String patient;
  final bool selectMember;
  final String? initialDepartment;
  final String? initialDoctor;
  final String? initialTime;
  final String? initialDate;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  static const _departments = ['Da liễu', 'Nội khoa', 'Tim mạch'];
  static const _doctors = <_DoctorOption>[
    _DoctorOption('BS. Trần Thu Hà', 'Da liễu'),
    _DoctorOption('BS. Lê Hoàng Nam', 'Nội khoa'),
    _DoctorOption('BS. Nguyễn Minh Anh', 'Tim mạch'),
  ];
  static const _times = ['06:00', '06:30', '07:00', '07:30', '08:00', '08:30'];

  final _problemController = TextEditingController();
  String _bookingMode = 'doctor';
  String? _department;
  _DoctorOption? _doctor;
  String? _appointmentTime;
  UserProfile? _selectedFamilyMember;
  bool _recordingVoice = false;
  final List<String> _attachments = [];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _department = widget.initialDepartment;
    for (final doctor in _doctors) {
      if (doctor.name == widget.initialDoctor) {
        _doctor = doctor;
        break;
      }
    }
    _appointmentTime = widget.initialTime;
    final rawDate = widget.initialDate;
    if (rawDate != null) _selectedDate = DateTime.tryParse(rawDate);
  }

  UserProfile? get _patient => switch (widget.patient) {
        'family' => _selectedFamilyMember,
        _ => MockData.user,
      };

  bool get _isFormValid =>
      _patient != null &&
      _department != null &&
      _doctor != null &&
      _appointmentTime != null &&
      _problemController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  Future<T?> _chooseOption<T>({
    required String title,
    required List<T> options,
    required String Function(T) labelOf,
  }) {
    return showModalBottomSheet<T>(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: options
                    .map((option) => ListTile(
                          title: Text(labelOf(option)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).pop(option),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseDepartment() async {
    final selected = await _chooseOption<String>(
      title: 'Chọn khoa',
      options: _departments,
      labelOf: (value) => value,
    );
    if (selected == null || !mounted) return;
    setState(() {
      _department = selected;
      if (_doctor?.department != selected) _doctor = null;
      _appointmentTime = null;
    });
  }

  Future<void> _chooseDoctor() async {
    if (_bookingMode == 'specialty' && _department == null) {
      _showMessage('Vui lòng chọn khoa trước');
      return;
    }
    final availableDoctors = _department == null
        ? _doctors
        : _doctors.where((doctor) => doctor.department == _department).toList();
    final selected = await _chooseOption<_DoctorOption>(
      title: 'Chọn bác sĩ',
      options: availableDoctors,
      labelOf: (doctor) => '${doctor.name} • ${doctor.department}',
    );
    if (selected == null || !mounted) return;
    setState(() {
      _doctor = selected;
      _department = selected.department;
      _appointmentTime = null;
    });
  }

  Future<void> _chooseTime() async {
    if (_doctor == null) return;
    final selected = await _chooseOption<String>(
      title: 'Chọn thời gian khám',
      options: _times,
      labelOf: (value) => value,
    );
    if (selected == null || !mounted) return;
    setState(() => _appointmentTime = selected);
  }

  Future<void> _chooseFamilyMember() async {
    final member = await showModalBottomSheet<UserProfile>(
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
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                'Chọn thành viên',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            ...MockData.familyMembers.map(
              (member) => ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFD9EBFC),
                  foregroundColor: AppColors.primary,
                  child: Icon(Icons.person),
                ),
                title: Text(member.name),
                subtitle: Text('SĐT: ${member.phone}'),
                onTap: () => Navigator.of(context).pop(member),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    if (member != null && mounted) {
      setState(() => _selectedFamilyMember = member);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _submitBooking() {
    final patient = _patient;
    if (!_isFormValid || patient == null || _doctor == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final parts = _appointmentTime!.split(':');
    final day = _selectedDate ?? DateTime(2026, 11, 20);
    final dateTime = DateTime(
      day.year,
      day.month,
      day.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    context.push(
      '/booking/confirm',
      extra: BookingDraft(
        patientName: patient.name,
        department: _department!,
        doctor: _doctor!.name,
        appointmentDateTime: dateTime,
        facility: 'BV Da liễu Trung ương',
        healthConcern: _problemController.text.trim(),
        attachments: List.unmodifiable(_attachments),
      ),
    );
  }

  void _addMockAttachment(String source) {
    setState(() => _attachments.add('$source ${_attachments.length + 1}'));
    _showMessage('Đã thêm ảnh minh họa');
  }

  @override
  Widget build(BuildContext context) {
    final patient = _patient;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Đặt lịch khám',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: () => context.go('/home'),
          icon: const Icon(
            Icons.chevron_left,
            size: 34,
            color: AppColors.textPrimary,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.48, 1],
                  colors: [Color(0xFF8DB8FF), Colors.white, Colors.white],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.paddingOf(context).top + kToolbarHeight + 10,
                16,
                24,
              ),
              children: [
                _BookingModeToggle(
                  selected: _bookingMode,
                  onChanged: (mode) => setState(() {
                    _bookingMode = mode;
                    _department = null;
                    _doctor = null;
                    _appointmentTime = null;
                  }),
                ),
                const SizedBox(height: 22),
                _patientCard(patient),
                const SizedBox(height: 16),
                _visitInformationCard(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isFormValid ? _submitBooking : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.48),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Đặt lịch khám',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _patientCard(UserProfile? patient) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFF2C48E), width: 1.2),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_add_alt_1,
                    color: AppColors.primary, size: 24),
                const SizedBox(width: 10),
                const _RequiredTitle('Người tới khám'),
                const Spacer(),
                if (widget.patient == 'family')
                  TextButton(
                    onPressed: _chooseFamilyMember,
                    child: Text(patient == null ? 'Chọn' : 'Thay đổi'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (patient == null)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAF3FC),
                  child: Icon(Icons.person_outline, color: AppColors.primary),
                ),
                title: const Text('Chọn thành viên gia đình'),
                onTap: _chooseFamilyMember,
              )
            else
              Row(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFB8C3D1)),
                      color: const Color(0xFFF7FAFD),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 42,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ngày sinh: ${_formatDate(patient.birthDate)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'SĐT: ${patient.phone}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const Divider(height: 18),
            InkWell(
              onTap: () => _showMessage('Danh sách cơ sở (bản demo)'),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.primary, size: 23),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'XEM LỊCH KHÁM TẤT CẢ CÁC CƠ SỞ',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _visitInformationCard() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
              child: const _RequiredTitle('Thông tin khám', fontSize: 19),
            ),
            _SelectionRow(
              icon: Icons.medical_services_outlined,
              label: 'Khoa',
              value: _department ?? 'Tất cả các khoa',
              onTap: _chooseDepartment,
            ),
            const Divider(height: 1, indent: 18, endIndent: 18),
            _SelectionRow(
              icon: Icons.person_outline,
              label: 'Bác sĩ',
              value: _doctor?.name ?? 'Chọn bác sĩ',
              onTap: _chooseDoctor,
              valueColor: _doctor == null
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
            Opacity(
              opacity: _doctor == null ? 0.42 : 1,
              child: _SelectionRow(
                icon: Icons.access_time,
                label: 'Thời gian khám',
                value: _appointmentTime ?? 'Chọn thời gian khám',
                onTap: _doctor == null ? null : _chooseTime,
                valueColor: _appointmentTime == null
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
            const Divider(height: 1, indent: 18, endIndent: 18),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.more_horiz,
                      color: AppColors.textSecondary, size: 24),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RequiredTitle('Vấn đề sức khỏe đang gặp phải'),
                        SizedBox(height: 4),
                        Text(
                          'Sử dụng giọng nói để mô tả thay cho nhập văn bản',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Mô tả bằng giọng nói',
                    onPressed: () {
                      final startRecording = !_recordingVoice;
                      setState(() => _recordingVoice = startRecording);
                      if (startRecording) {
                        _showMessage(
                          'Nhập giọng nói chưa khả dụng trong bản demo',
                        );
                      }
                    },
                    icon: Icon(
                      _recordingVoice ? Icons.mic : Icons.mic_none,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: TextField(
                controller: _problemController,
                onChanged: (_) => setState(() {}),
                minLines: 4,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText:
                      'Bạn vui lòng mô tả vấn đề bạn gặp phải chúng tôi sẽ hỗ trợ bạn Ví dụ: mọc mụn nước ở tay',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: const Color(0xFFF4F5F7),
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _addMockAttachment('Ảnh chụp'),
                      icon: const Icon(Icons.camera_alt_outlined,
                          color: AppColors.secondaryGreen),
                      label: const Text('Chụp ảnh'),
                      style: _attachmentButtonStyle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _addMockAttachment('Ảnh tải lên'),
                      icon: const Icon(Icons.attach_file,
                          color: AppColors.primary),
                      label: const Text('Tải ảnh lên'),
                      style: _attachmentButtonStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  static final _attachmentButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.textSecondary,
    side: const BorderSide(color: Color(0xFFD9DDE3)),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _BookingModeToggle extends StatelessWidget {
  const _BookingModeToggle({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: 'Theo bác sĩ',
              isSelected: selected == 'doctor',
              onTap: () => onChanged('doctor'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ModeButton(
              label: 'Theo chuyên khoa',
              isSelected: selected == 'specialty',
              onTap: () => onChanged('specialty'),
            ),
          ),
        ],
      );
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 56,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: isSelected ? AppColors.primary : Colors.white,
            foregroundColor:
                isSelected ? Colors.white : AppColors.textSecondary,
            shape: const StadiumBorder(),
            elevation: isSelected ? 1 : 0,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.valueColor = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Color valueColor;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
            children: [
              Icon(icon, color: onTap == null ? AppColors.textSecondary : AppColors.primary, size: 25),
              const SizedBox(width: 12),
              _RequiredTitle(label),
              const Spacer(),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onTap == null ? AppColors.textSecondary : valueColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: onTap == null
                    ? AppColors.textSecondary.withOpacity(0.55)
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      );
}

class _RequiredTitle extends StatelessWidget {
  const _RequiredTitle(this.label, {this.fontSize = 16});
  final String label;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Text.rich(
        TextSpan(
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(text: label),
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.danger),
            ),
          ],
        ),
      );
}

class _DoctorOption {
  const _DoctorOption(this.name, this.department);
  final String name;
  final String department;
}
