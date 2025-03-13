import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/module/data/models/study_module_model.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card_item.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';

class RecommendedModules extends StatelessWidget {
  final List<StudyModule> modules;
  final VoidCallback? onViewAll;
  final Function(StudyModule)? onModuleTap;

  const RecommendedModules({
    super.key,
    required this.modules,
    this.onViewAll,
    this.onModuleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) {
      return const QlzEmptyState(
        title: 'Chưa có gợi ý học phần',
        message: 'Học càng nhiều, gợi ý càng chính xác',
        icon: Icons.school_outlined,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GỢI Ý HỌC PHẦN',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      // Đồng bộ với Theme
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                      fontSize: 16, // Chuẩn 16sp
                    ),
              ),
              if (modules.length > 3)
                GestureDetector(
                  onTap: onViewAll,
                  child: Row(
                    children: [
                      Text(
                        'Xem tất cả',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14, // Chuẩn 14sp
                              color: AppColors.primary, // Đồng bộ với AppColors
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios,
                          size: 12, color: AppColors.primary),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12), // Giảm từ 16 xuống 12
        _buildModuleList(),
      ],
    );
  }

  Widget _buildModuleList() {
    final displayModules = modules.length > 3 ? modules.sublist(0, 3) : modules;
    return ListView.builder(
      shrinkWrap: true, // Đảm bảo ListView không chiếm toàn bộ màn hình
      physics: const NeverScrollableScrollPhysics(), // Tắt cuộn riêng
      itemCount: displayModules.length,
      itemBuilder: (context, index) {
        return _buildModuleCard(context, displayModules[index]);
      },
    );
  }

  Widget _buildModuleCard(BuildContext context, StudyModule module) {
    return Container(
      margin: const EdgeInsets.only(
          bottom: 12, left: 16, right: 16), // Giảm từ 16 xuống 12
      child: QlzCardItem(
        icon: Icons.menu_book_outlined,
        iconColor: AppColors.primary, // Thay Colors.blue
        title: module.title,
        subtitle:
            '${module.creatorName} • ${module.termCount} từ${module.hasPlusBadge ? ' • Plus' : ''}',
        titleStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14, // Chuẩn 14sp
              color: AppColors.darkText,
            ),
        subtitleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12, // Chuẩn 12sp
              color: AppColors.darkTextSecondary.withOpacity(0.85),
            ),
        trailing: const Icon(Icons.arrow_forward_ios,
            color: Colors.white54, size: 16),
        onTap: () => onModuleTap?.call(module),
      ),
    );
  }
}
