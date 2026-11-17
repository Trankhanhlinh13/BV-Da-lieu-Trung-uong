import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    this.length = 6,
    this.hasError = false,
    this.errorNonce = 0,
    this.onChanged,
  });

  final int length;
  final bool hasError;
  final int errorNonce;
  final ValueChanged<String>? onChanged;

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> with SingleTickerProviderStateMixin {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final AnimationController _shakeController;
  late final Animation<double> _shake;
  bool _previousError = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    for (final node in _focusNodes) {
      node.addListener(_handleFocusChange);
    }
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(covariant OtpInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError &&
        (!_previousError || oldWidget.errorNonce != widget.errorNonce)) {
      _shakeController.forward(from: 0);
    }
    _previousError = widget.hasError;
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  String get _value => _controllers.map((controller) => controller.text).join();

  void _handleChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.isEmpty) return;
      final count = (widget.length - index).clamp(0, digits.length).toInt();
      for (var offset = 0; offset < count; offset++) {
        final target = index + offset;
        _controllers[target].value = TextEditingValue(
          text: digits[offset],
          selection: const TextSelection.collapsed(offset: 1),
        );
      }
      final focusIndex = (index + count).clamp(0, widget.length - 1).toInt();
      _focusNodes[focusIndex].requestFocus();
      widget.onChanged?.call(_value);
      setState(() {});
      return;
    }

    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    widget.onChanged?.call(_value);
    setState(() {});
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.removeListener(_handleFocusChange);
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _shake,
        builder: (context, child) => Transform.translate(
          offset: Offset(widget.hasError ? _shake.value : 0, 0),
          child: child,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const gap = 8.0;
            final itemWidth = (constraints.maxWidth - gap * (widget.length - 1)) /
                widget.length;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(widget.length, (index) {
                final focused = _focusNodes[index].hasFocus;
                final color = widget.hasError
                    ? AppColors.danger
                    : focused
                        ? AppColors.primary
                        : const Color(0xFFE2E4E8);
                return SizedBox(
                  width: itemWidth,
                  height: 54,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    autofillHints:
                        index == 0 ? const [AutofillHints.oneTimeCode] : null,
                    textAlign: TextAlign.center,
                    textInputAction: index == widget.length - 1
                        ? TextInputAction.done
                        : TextInputAction.next,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => _handleChanged(index, value),
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: color, width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: color, width: 1.8),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      );
}
