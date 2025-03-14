import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card_item.dart';

class StudyStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final bool showBorder;
  final VoidCallback? onTap;

  const StudyStatsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.showBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (title.isEmpty || value.isEmpty) {
      return const QlzCardItem(
        icon: Icons.error_outline,
        iconColor: Colors.red,
        title: 'Lỗi dữ liệu',
        subtitle: 'Thông tin không đầy đủ',
      );
    }

    // Tạo một container để bo tròn hiệu ứng InkWell
    return Material(
      color: Colors.transparent, // Để hiện thị đúng màu nền
      borderRadius: BorderRadius.circular(12), // Bo tròn cả thẻ và hiệu ứng
      clipBehavior:
          Clip.antiAlias, // Đảm bảo hiệu ứng không vượt ra ngoài bo tròn
      child: Ink(
        // Ink thay vì Container để hiệu ứng InkWell hoạt động đúng
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkCard
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          // Có thể tuỳ chỉnh màu splash nếu cần
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ??
                        (iconColor?.withOpacity(0.2) ??
                            AppColors.primary.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              color:
                                  AppColors.darkTextSecondary.withOpacity(0.85),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getValueText(),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
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
    );
  }

  String _getValueText() {
    if (subtitle == null) return value;
    return '$value\n$subtitle';
  }
}
