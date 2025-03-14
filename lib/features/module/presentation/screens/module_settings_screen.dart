// lib/features/module/presentation/screens/module_settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/module/presentation/providers/module_settings_provider.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/layout/qlz_modal.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

class ModuleSettingsScreen extends ConsumerWidget {
  final String moduleId;

  const ModuleSettingsScreen({
    super.key,
    this.moduleId = 'new', // Default for new modules
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateNotifier = ref.watch(moduleSettingsProvider(moduleId).notifier);
    final state = ref.watch(moduleSettingsProvider(moduleId));

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
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
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
                  stateNotifier.loadSettings();
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'NGÔN NGỮ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingSection([
                _buildLanguageRow(
                  context,
                  'Thuật ngữ',
                  settings.termLanguage,
                  onTap: () {
                    HapticFeedback.selectionClick();
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: Colors.white24, height: 1),
                ),
                _buildLanguageRow(
                  context,
                  'Định nghĩa',
                  settings.definitionLanguage,
                  onTap: () {
                    HapticFeedback.selectionClick();
                  },
                ),
              ]),
              const SizedBox(height: 32),
              const Text(
                'TÙY CHỌN',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingSection([
                _buildSwitchRow(
                  'Gợi ý tự động',
                  value: settings.autoSuggest,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    stateNotifier.updateAutoSuggest(value);
                  },
                ),
              ]),
              const SizedBox(height: 32),
              const Text(
                'QUYỀN RIÊNG TƯ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingSection([
                _buildPermissionRow(
                  context,
                  'Ai có thể xem',
                  settings.viewPermission,
                  ['Mọi người', 'Chỉ tôi'],
                  (value) {
                    stateNotifier.updateViewPermission(value);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: Colors.white24, height: 1),
                ),
                _buildPermissionRow(
                  context,
                  'Ai có thể sửa',
                  settings.editPermission,
                  ['Mọi người', 'Chỉ tôi'],
                  (value) {
                    stateNotifier.updateEditPermission(value);
                  },
                ),
              ]),
              if (moduleId != 'new') ...[
                const SizedBox(height: 32),
                QlzButton.danger(
                  label: 'Xóa học phần',
                  icon: Icons.delete_outline,
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    _showDeleteConfirmation(context);
                  },
                  isFullWidth: true,
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
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
        Navigator.pop(context);
      }
    });
  }

  Widget _buildSettingSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12113A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildLanguageRow(
    BuildContext context,
    String title,
    String value, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
    BuildContext context,
    String title,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                _showPermissionOptions(
                    context, title, value, options, onChanged);
              },
            ),
          ],
        ),
      ),
      onTap: () {
        HapticFeedback.selectionClick();
        _showPermissionOptions(context, title, value, options, onChanged);
      },
    );
  }

  void _showPermissionOptions(
    BuildContext context,
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
