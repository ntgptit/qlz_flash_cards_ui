// lib/features/module/data/models/module_settings_model.dart
import 'package:equatable/equatable.dart';

class ModuleSettings extends Equatable {
  final String termLanguage;
  final String definitionLanguage;
  final bool autoSuggest;
  final String viewPermission;
  final String editPermission;

  const ModuleSettings({
    this.termLanguage = 'Tiếng Việt',
    this.definitionLanguage = 'Tiếng Hàn',
    this.autoSuggest = true,
    this.viewPermission = 'Mọi người',
    this.editPermission = 'Chỉ tôi',
  });

  @override
  List<Object?> get props => [
        termLanguage,
        definitionLanguage,
        autoSuggest,
        viewPermission,
        editPermission,
      ];

  ModuleSettings copyWith({
    String? termLanguage,
    String? definitionLanguage,
    bool? autoSuggest,
    String? viewPermission,
    String? editPermission,
  }) {
    return ModuleSettings(
      termLanguage: termLanguage ?? this.termLanguage,
      definitionLanguage: definitionLanguage ?? this.definitionLanguage,
      autoSuggest: autoSuggest ?? this.autoSuggest,
      viewPermission: viewPermission ?? this.viewPermission,
      editPermission: editPermission ?? this.editPermission,
    );
  }

  factory ModuleSettings.fromJson(Map<String, dynamic> json) {
    return ModuleSettings(
      termLanguage: json['termLanguage'] as String? ?? 'Tiếng Việt',
      definitionLanguage: json['definitionLanguage'] as String? ?? 'Tiếng Hàn',
      autoSuggest: json['autoSuggest'] as bool? ?? true,
      viewPermission: json['viewPermission'] as String? ?? 'Mọi người',
      editPermission: json['editPermission'] as String? ?? 'Chỉ tôi',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'termLanguage': termLanguage,
      'definitionLanguage': definitionLanguage,
      'autoSuggest': autoSuggest,
      'viewPermission': viewPermission,
      'editPermission': editPermission,
    };
  }
}