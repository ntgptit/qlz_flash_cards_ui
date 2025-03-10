import 'package:flutter/material.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('GỢI Ý HỌC PHẦN',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              if (modules.length > 3)
                GestureDetector(
                  onTap: onViewAll,
                  child: const Row(
                    children: [
                      Text('Xem tất cả',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios,
                          size: 12, color: Colors.blue),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        modules.isEmpty
            ? const QlzEmptyState(
                title: 'Chưa có gợi ý học phần',
                message: 'Học càng nhiều, gợi ý càng chính xác',
                icon: Icons.school_outlined,
              )
            : _buildModuleList(),
      ],
    );
  }

  Widget _buildModuleList() {
    final displayModules = modules.length > 3 ? modules.sublist(0, 3) : modules;
    return Column(
      children:
          displayModules.map((module) => _buildModuleCard(module)).toList(),
    );
  }

  Widget _buildModuleCard(StudyModule module) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
      child: QlzCardItem(
        icon: Icons.menu_book_outlined,
        iconColor: Colors.blue,
        title: module.title,
        subtitle:
            '${module.creatorName} • ${module.termCount} từ${module.hasPlusBadge ? ' • Plus' : ''}',
        trailing: const Icon(Icons.arrow_forward_ios,
            color: Colors.white54, size: 16),
        onTap: () => onModuleTap?.call(module),
      ),
    );
  }
}
