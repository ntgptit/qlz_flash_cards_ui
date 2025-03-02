import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

/// A customized text field component with consistent styling
/// and advanced features.
final class QlzTextField extends StatefulWidget {
  /// Controller for the text field
  final TextEditingController? controller;

  /// Label text displayed above the text field
  final String? label;

  /// Placeholder text inside the text field when empty
  final String hintText;

  /// Helper text displayed below the text field
  final String? helper;

  /// Error text displayed below the text field (overrides helper text)
  final String? error;

  /// Optional prefix icon
  final IconData? prefixIcon;

  /// Optional suffix icon
  final IconData? suffixIcon;

  /// Callback when suffix icon is tapped
  final VoidCallback? onSuffixIconTap;

  /// Whether the field is required
  final bool isRequired;

  /// Whether the field is disabled
  final bool isDisabled;

  /// Whether to obscure text (for passwords)
  final bool isPassword;

  /// Whether the field allows multiple lines
  final bool isMultiline;

  /// Input type (e.g., email, number)
  final TextInputType? keyboardType;

  /// Input action (e.g., next, done)
  final TextInputAction? textInputAction;

  /// Callback when text changes
  final ValueChanged<String>? onChanged;

  /// Callback when text is submitted
  final ValueChanged<String>? onSubmitted;

  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Maximum character length
  final int? maxLength;

  /// Whether the field should autofocus
  final bool autofocus;

  /// Focus node for programmatic control
  final FocusNode? focusNode;

  /// **Constructor for a general text field**
  const QlzTextField({
    super.key,
    this.controller,
    this.label,
    required this.hintText,
    this.helper,
    this.error,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.isRequired = false,
    this.isDisabled = false,
    this.isPassword = false,
    this.isMultiline = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.maxLength,
    this.autofocus = false,
    this.focusNode,
  });

  /// **Factory constructor for an email text field**
  const QlzTextField.email({
    super.key,
    this.controller,
    this.label = 'Email',
    this.error,
    this.isRequired = true,
    this.isDisabled = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.autofocus = false,
  })  : hintText = 'Enter your email',
        helper = null,
        prefixIcon = Icons.email_outlined,
        suffixIcon = null,
        onSuffixIconTap = null,
        isPassword = false,
        isMultiline = false,
        keyboardType = TextInputType.emailAddress,
        inputFormatters = null,
        maxLength = null;

  /// **Factory constructor for a password text field**
  const QlzTextField.password({
    super.key,
    this.controller,
    this.label = 'Password',
    this.error,
    this.isRequired = true,
    this.isDisabled = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.done,
    this.focusNode,
    this.autofocus = false,
  })  : hintText = 'Enter your password',
        helper = null,
        prefixIcon = Icons.lock_outline,
        suffixIcon = Icons.visibility_outlined,
        onSuffixIconTap = null,
        isPassword = true,
        isMultiline = false,
        keyboardType = null,
        inputFormatters = null,
        maxLength = null;

  /// **Factory constructor for a search text field**
  const QlzTextField.search({
    super.key,
    this.controller,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    VoidCallback? onClear,
    this.focusNode,
    this.autofocus = false,
  })  : label = null,
        helper = null,
        error = null,
        prefixIcon = Icons.search,
        suffixIcon = Icons.clear,
        onSuffixIconTap = onClear,
        isRequired = false,
        isDisabled = false,
        isPassword = false,
        isMultiline = false,
        keyboardType = TextInputType.text,
        textInputAction = TextInputAction.search,
        inputFormatters = null,
        maxLength = null;

  @override
  State<QlzTextField> createState() => _QlzTextFieldState();
}

final class _QlzTextFieldState extends State<QlzTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.error != null && widget.error!.isNotEmpty;
    final bool hasSuffixIcon = widget.suffixIcon != null || widget.isPassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// **Label**
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
        ],

        /// **Text Field**
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle:
                TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
            errorText: hasError ? '' : null,
            filled: true,
            fillColor: const Color(0xFF12113A),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon,
                    color: Colors.white.withOpacity(0.7), size: 20)
                : null,
            suffixIcon: hasSuffixIcon ? _buildSuffixIcon() : null,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: AppColors.primary,
          obscureText: _obscureText,
          maxLines: widget.isMultiline ? 5 : 1,
          keyboardType: widget.isMultiline
              ? TextInputType.multiline
              : widget.keyboardType,
          textInputAction: widget.textInputAction ?? TextInputAction.next,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
        ),
      ],
    );
  }

  /// **Suffix icon logic (toggle visibility for passwords)**
  Widget _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return IconButton(
      icon: Icon(widget.suffixIcon,
          color: Colors.white.withOpacity(0.7), size: 20),
      onPressed: widget.onSuffixIconTap,
    );
  }
}
