import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_dropdown.dart';

/// A dropdown widget for filtering content
class FilterDropdown extends StatelessWidget {
  /// The available filter options
  final List<String> options;

  /// The currently selected option
  final String selectedOption;

  /// Callback when an option is selected
  final ValueChanged<String> onSelected;

  const FilterDropdown({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
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
