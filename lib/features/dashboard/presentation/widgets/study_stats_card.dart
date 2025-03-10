import 'package:flutter/material.dart';
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: QlzCardItem(
        icon: icon,
        iconColor: iconColor ?? Colors.blue,
        iconBackgroundColor: iconBackgroundColor,
        title: title,
        subtitle: subtitle != null ? '$value\n$subtitle' : value,
        titleStyle: const TextStyle(
            fontSize: 14, color: Color.fromRGBO(255, 255, 255, 0.7)),
        subtitleStyle: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}
