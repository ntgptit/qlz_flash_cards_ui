qlz_flash_cards_ui
│── lib
│   │── main.dart
│   │── config/
│   │   │── app_colors.dart
│   │   │── app_config.dart
│   │   │── app_theme.dart
│   │
│   │── core/
│   │   │── routes/
│   │   │   │── app_routes.dart
│   │   │── api/
│   │   │   │── api_provider.dart
│   │   │   │── api_error.dart
│   │   │   │── network_error.dart
│   │   │   │── endpoints.dart
│   │   │── utils/
│   │   │   │── helpers.dart
│   │   │   │── validators.dart
│   │   │── services/
│   │   │   │── auth_service.dart
│   │   │   │── flashcard_service.dart
│   │   │   │── vocabulary_service.dart
│   │
│   │── models/
│   │   │── user.dart
│   │   │── flashcard.dart
│   │   │── vocabulary.dart
│   │   │── study_option.dart
│   │
│   │── shared/
│   │   │── constants/
│   │   │   │── strings.dart
│   │   │── widgets/
│   │   │   │── inputs/
│   │   │   │   │── qlz_text_field.dart
│   │   │   │   │── qlz_button.dart
│   │   │   │── cards/
│   │   │   │   │── qlz_card.dart
│   │   │   │── quiz/
│   │   │   │   │── qlz_quiz_option.dart
│   │   │   │── study/
│   │   │   │   │── qlz_flashcard.dart
│   │   │   │── labels/
│   │   │   │   │── qlz_label.dart
│
│   │── features/
│   │   │── auth/
│   │   │   │── screens/
│   │   │   │   │── forgot_password_screen.dart
│   │   │   │   │── register_screen.dart
│   │   │   │   │── login_screen.dart
│   │   │   │── repository/
│   │   │   │   │── auth_repository.dart
│   │   │
│   │   │── class/
│   │   │   │── create_class_screen.dart
│   │   │
│   │   │── flashcard/
│   │   │   │── screens/
│   │   │   │   │── flashcard_study_mode_screen.dart
│   │   │   │── repository/
│   │   │   │   │── flashcard_repository.dart
│   │   │
│   │   │── folder/
│   │   │   │── screens/
│   │   │   │   │── create_folder_screen.dart
│   │   │   │   │── folder_detail_screen.dart
│   │   │
│   │   │── home/
│   │   │   │── home_screen.dart
│   │   │   │── tabs/
│   │   │   │   │── home_tab.dart
│   │   │   │   │── solutions_tab.dart
│   │
│   │   │── library/
│   │   │   │── library_screen.dart
│   │
│   │   │── module/
│   │   │   │── screens/
│   │   │   │   │── list_study_module_of_folder_screen.dart
│   │   │   │   │── module_settings_screen.dart
│   │   │   │   │── create_study_module_screen.dart
│   │   │   │   │── module_detail_screen.dart
│   │   │   │── repository/
│   │   │   │   │── module_repository.dart
│   │
│   │   │── profile/
│   │   │   │── profile_screen.dart
│   │
│   │   │── quiz/
│   │   │   │── quiz_screen.dart
│   │
│   │   │── study/
│   │   │   │── flashcard_screen.dart
│   │
│   │   │── vocabulary/
│   │   │   │── screens/
│   │   │   │   │── vocabulary_screen.dart
│   │   │   │── cubit/
│   │   │   │   │── vocabulary_cubit.dart
│   │   │   │   │── vocabulary_state.dart
│   │   │   │── repository/
│   │   │   │   │── vocabulary_repository.dart
│   │   │   │── widgets/
│   │   │   │   │── term_list.dart
│   │   │   │   │── study_progress.dart
│   │   │   │   │── study_options_list.dart
│   │   │   │   │── module_user_info.dart
│   │   │   │   │── flashcard_carousel.dart
│   │
│   │   │── welcome_screen.dart
