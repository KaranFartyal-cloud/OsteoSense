import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

enum TextFieldVariant {
  default_,
  outlined,
  underlined,
}

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final int? maxLines;
  final int? maxLength;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextFieldVariant variant;
  final bool autofocus;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.variant = TextFieldVariant.default_,
    this.autofocus = false,
    this.validator,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  bool _obscureText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final colors = _getTextFieldColors();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.labelMedium.copyWith(
              color: hasError ? AppColors.error : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: TextFormField(
            controller: _controller,
            obscureText: _obscureText,
            enabled: widget.enabled,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            autofocus: widget.autofocus,
            validator: widget.validator,
            inputFormatters: widget.inputFormatters,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            style: AppTypography.bodyMedium.copyWith(
              color: widget.enabled ? AppColors.textPrimary : AppColors.textTertiary,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon ??
                  (widget.obscureText
                      ? IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: _toggleObscureText,
                        )
                      : null),
              counterText: null,
              filled: true,
              fillColor: widget.enabled
                  ? colors.fillColor
                  : AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              border: _getInputBorder(colors),
              enabledBorder: _getInputBorder(colors),
              focusedBorder: _getInputBorder(colors, isFocused: true),
              errorBorder: _getInputBorder(colors, hasError: true),
              focusedErrorBorder: _getInputBorder(colors, hasError: true, isFocused: true),
              hintStyle: AppTypography.hintText(AppColors.textHint),
              floatingLabelStyle: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ).animate().fadeIn(duration: 300.ms),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.errorText!,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.error,
            ),
          ).animate().fadeIn(duration: 300.ms),
        ],
      ],
    );
  }

  OutlineInputBorder _getInputBorder(_TextFieldColors colors, {bool isFocused = false, bool hasError = false}) {
    final borderColor = hasError
        ? AppColors.error
        : isFocused
            ? AppColors.primary
            : colors.borderColor;

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: BorderSide(
        color: borderColor,
        width: isFocused ? 2 : 1,
      ),
    );
  }

  _TextFieldColors _getTextFieldColors() {
    switch (widget.variant) {
      case TextFieldVariant.outlined:
        return _TextFieldColors(
          fillColor: AppColors.surfaceVariant,
          borderColor: AppColors.border,
        );
      case TextFieldVariant.underlined:
        return _TextFieldColors(
          fillColor: Colors.transparent,
          borderColor: AppColors.divider,
        );
      case TextFieldVariant.default_:
      default:
        return _TextFieldColors(
          fillColor: AppColors.surfaceVariant,
          borderColor: AppColors.border,
        );
    }
  }
}

class _TextFieldColors {
  final Color fillColor;
  final Color borderColor;

  _TextFieldColors({
    required this.fillColor,
    required this.borderColor,
  });
}
