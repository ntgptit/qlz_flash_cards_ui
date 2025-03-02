import 'package:flutter/material.dart';

/// A custom dropdown widget styled according to the app's design.
final class QlzDropdown<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint, helperText, errorText;
  final bool isDisabled;
  final Color? backgroundColor, borderColor;
  final double borderWidth;
  final double? height, width;
  final Widget? icon;

  const QlzDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.hint,
    this.helperText,
    this.errorText,
    this.isDisabled = false,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.height,
    this.width,
    this.icon,
  });

  @override
  State<QlzDropdown<T>> createState() => _QlzDropdownState<T>();
}

class _QlzDropdownState<T> extends State<QlzDropdown<T>> {
  bool _isDropdownOpen = false;

  @override
  Widget build(BuildContext context) {
    final colors = _getEffectiveColors(context);
    final textStyle = TextStyle(
        color: widget.isDisabled ? colors['disabled'] : colors['text']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: widget.isDisabled
              ? null
              : () => setState(() => _isDropdownOpen = !_isDropdownOpen),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: widget.height ?? 48,
            width: widget.width,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colors['background'],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: colors['border']!, width: widget.borderWidth),
            ),
            child: Row(
              children: [
                Expanded(
                    child: Text(_getDisplayText(),
                        style: textStyle, overflow: TextOverflow.ellipsis)),
                widget.icon ??
                    Icon(
                      _isDropdownOpen
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                      color: colors['icon'],
                    ),
              ],
            ),
          ),
        ),
        if (_isDropdownOpen) _buildDropdownMenu(colors),
        if (widget.errorText != null || widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16),
            child: Text(
              widget.errorText ?? widget.helperText ?? '',
              style: TextStyle(color: colors['helper'], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Map<String, Color?> _getEffectiveColors(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return {
      'background': widget.backgroundColor ??
          (isDarkMode ? const Color(0xFF12113A) : theme.colorScheme.surface),
      'border': widget.errorText != null
          ? theme.colorScheme.error
          : (widget.borderColor ??
              (isDarkMode
                  ? const Color(0xFF2C2D4A)
                  : theme.colorScheme.outline)),
      'text': theme.colorScheme.onSurface,
      'icon': widget.isDisabled
          ? theme.disabledColor
          : theme.colorScheme.onSurface.withOpacity(0.7),
      'helper': widget.errorText != null
          ? theme.colorScheme.error
          : theme.colorScheme.onSurface.withOpacity(0.6),
      'disabled': theme.disabledColor,
    };
  }

  String _getDisplayText() {
    if (widget.value == null) return widget.hint ?? '';

    for (final item in widget.items) {
      if (item.value == widget.value) {
        return item.child is Text
            ? (item.child as Text).data ?? ''
            : widget.value.toString();
      }
    }
    return widget.value.toString();
  }

  Widget _buildDropdownMenu(Map<String, Color?> colors) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: colors['background'],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors['border']!, width: widget.borderWidth),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: widget.items.map((item) {
          final isSelected = item.value == widget.value;
          return InkWell(
            onTap: widget.isDisabled ? null : () => _selectItem(item.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(child: item.child),
                  if (isSelected)
                    Icon(Icons.check, color: colors['icon'], size: 18),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _selectItem(T? value) {
    widget.onChanged?.call(value);
    setState(() => _isDropdownOpen = false);
  }
}
