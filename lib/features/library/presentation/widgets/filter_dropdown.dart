// lib/features/library/presentation/widgets/filter_dropdown.dart
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_dropdown.dart';

/// Widget dropdown để lọc dữ liệu
class FilterDropdown extends StatelessWidget {
  /// Danh sách các tùy chọn lọc
  final List<String> options;

  /// Tùy chọn được chọn hiện tại
  final String selectedOption;

  /// Callback khi một tùy chọn được chọn
  final ValueChanged<String> onSelected;

  const FilterDropdown({
    required this.options,
    required this.selectedOption,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return QlzDropdown<String>(
      value: selectedOption,
      items: options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onSelected(value);
        }
      },
      hint: "Chọn bộ lọc",
      backgroundColor: AppColors.darkCard,
      borderColor: Colors.white.withOpacity(0.1),
    );
  }
}
