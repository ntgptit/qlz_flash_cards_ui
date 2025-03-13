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
      return Container(
        margin: const EdgeInsets.all(12), // Giảm từ 16 xuống 12
        child: const QlzCardItem(
          icon: Icons.error_outline,
          iconColor: Colors.red,
          title: 'Lỗi dữ liệu',
          subtitle: 'Thông tin không đầy đủ',
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.all(12), // Giảm từ 16 xuống 12
      child: QlzCardItem(
        icon: icon,
        iconColor: iconColor ?? AppColors.primary, // Đồng bộ màu
        iconBackgroundColor: iconBackgroundColor,
        title: title,
        subtitle: _getSubtitleText(),
        titleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14, // Chuẩn 14sp
              color:
                  AppColors.darkTextSecondary.withOpacity(0.85), // Tăng độ sáng
            ),
        subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 18, // Giảm từ 20 xuống 18
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
        onTap: onTap,
      ),
    );
  }

  String _getSubtitleText() {
    if (subtitle == null) return value;
    return '$value\n$subtitle';
  }
}
