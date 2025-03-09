import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';

final class QlzOptionItem extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// The label text.
  final String label;

  /// The subtitle text.
  final String subtitle;

  /// The callback when the option is tapped.
  final VoidCallback? onTap;

  /// The color of the icon and border.
  final Color? color;

  /// Whether this option is currently selected.
  final bool isSelected;

  /// Whether this option is currently disabled.
  final bool isDisabled;

  /// The height of the option item (default reduced by 15%).
  final double? height;

  const QlzOptionItem({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    this.onTap,
    this.color,
    this.isSelected = false,
    this.isDisabled = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final effectiveColor = color ?? AppColors.primary;
    final backgroundColor =
        isDarkMode ? AppColors.darkCard : theme.colorScheme.surface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding:
              const EdgeInsets.all(12), // Giảm padding để tối ưu không gian
          height:
              height ?? 68, // Giảm 15% so với kích thước ban đầu (~80 -> 68)
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? effectiveColor
                  : isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42, // Giảm kích thước icon container một chút
                height: 42,
                decoration: BoxDecoration(
                  color: effectiveColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: effectiveColor,
                  size: 22, // Giảm icon một chút
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                        height: 2), // Giảm khoảng cách giữa label và subtitle
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Tránh xuống dòng dài
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isDarkMode
                    ? Colors.white.withOpacity(0.7)
                    : Colors.black.withOpacity(0.7),
                size: 14, // Giảm kích thước icon điều hướng
              ),
            ],
          ),
        ),
      ),
    );
  }
}
