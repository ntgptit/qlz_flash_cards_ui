// C:/Users/ntgpt/OneDrive/workspace/qlz_flash_cards_ui/lib/features/module/screens/module_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/cubit/module_settings_cubit.dart';
import 'package:qlz_flash_cards_ui/features/module/logic/states/module_settings_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_modal.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

class ModuleSettingsScreen extends StatefulWidget {
  final String moduleId;

  const ModuleSettingsScreen({
    super.key,
    this.moduleId = 'new', // Default for new modules
  });

  @override
  State<ModuleSettingsScreen> createState() => _ModuleSettingsScreenState();
}

class _ModuleSettingsScreenState extends State<ModuleSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Không khởi tạo cubit ở đây nữa
    // Cubit được cung cấp qua BlocProvider
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModuleSettingsCubit, ModuleSettingsState>(
      builder: (context, state) {
        if (state.status == ModuleSettingsStatus.loading) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A092D),
            appBar: QlzAppBar(
              title: 'Cài đặt tùy chọn',
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.status == ModuleSettingsStatus.failure) {
          return Scaffold(
            backgroundColor: const Color(0xFF0A092D),
            appBar: const QlzAppBar(
              title: 'Cài đặt tùy chọn',
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'Đã xảy ra lỗi',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  QlzButton(
                    label: 'Thử lại',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      context.read<ModuleSettingsCubit>().loadSettings();
                    },
                  ),
                ],
              ),
            ),
          );
        }

        final settings = state.settings;

        return Scaffold(
          backgroundColor: const Color(0xFF0A092D),
          appBar: const QlzAppBar(
            title: 'Cài đặt tùy chọn',
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Text(
                    'NGÔN NGỮ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildSettingSection([
                  _buildLanguageRow(
                    'Thuật ngữ',
                    settings.termLanguage,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      // Hiển thị dialog chọn ngôn ngữ
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(color: Colors.white24, height: 1),
                  ),
                  _buildLanguageRow(
                    'Định nghĩa',
                    settings.definitionLanguage,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      // Hiển thị dialog chọn ngôn ngữ
                    },
                  ),
                ]),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    'TÙY CHỌN',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildSettingSection([
                  _buildSwitchRow(
                    'Gợi ý tự động',
                    value: settings.autoSuggest,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      context
                          .read<ModuleSettingsCubit>()
                          .updateAutoSuggest(value);
                    },
                  ),
                ]),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 32, 20, 12),
                  child: Text(
                    'QUYỀN RIÊNG TƯ',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildSettingSection([
                  _buildPermissionRow(
                    'Ai có thể xem',
                    settings.viewPermission,
                    ['Mọi người', 'Chỉ tôi'],
                    (value) {
                      context
                          .read<ModuleSettingsCubit>()
                          .updateViewPermission(value);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Divider(color: Colors.white24, height: 1),
                  ),
                  _buildPermissionRow(
                    'Ai có thể sửa',
                    settings.editPermission,
                    ['Mọi người', 'Chỉ tôi'],
                    (value) {
                      context
                          .read<ModuleSettingsCubit>()
                          .updateEditPermission(value);
                    },
                  ),
                ]),
                const SizedBox(height: 32),
                if (widget.moduleId != 'new')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: QlzButton.danger(
                      label: 'Xóa học phần',
                      icon: Icons.delete_outline,
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        _showDeleteConfirmation();
                      },
                      isFullWidth: true,
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation() {
    QlzModal.showConfirmation(
      context: context,
      title: 'Xóa học phần',
      message:
          'Bạn có chắc chắn muốn xóa học phần này không? Hành động này không thể hoàn tác.',
      confirmText: 'Xóa',
      cancelText: 'Hủy',
      isDanger: true,
    ).then((confirmed) {
      if (confirmed) {
        // Xóa học phần và quay lại màn hình trước
        Navigator.pop(context);
      }
    });
  }

  Widget _buildSettingSection(List<Widget> children) {
    return QlzCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildLanguageRow(
    String title,
    String value, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchRow(
    String title, {
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildPermissionRow(
    String title,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: SizedBox(
        width: 120,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.chevron_right,
                  color: Colors.white54, size: 20),
              onPressed: () {
                HapticFeedback.selectionClick();
                _showPermissionOptions(title, value, options, onChanged);
              },
            ),
          ],
        ),
      ),
      onTap: () {
        HapticFeedback.selectionClick();
        _showPermissionOptions(title, value, options, onChanged);
      },
    );
  }

  void _showPermissionOptions(
    String title,
    String currentValue,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    QlzModal.showBottomSheet(
      context: context,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          final isSelected = option == currentValue;
          return ListTile(
            title: Text(
              option,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged(option);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
