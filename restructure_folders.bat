@echo off
set BASE_DIR=D:\Work\workspace\qlz_flash_cards_ui\lib

:: Tạo thư mục mới
mkdir "%BASE_DIR%\config"
mkdir "%BASE_DIR%\core\api"
mkdir "%BASE_DIR%\core\routes"
mkdir "%BASE_DIR%\core\utils"
mkdir "%BASE_DIR%\core\services"
mkdir "%BASE_DIR%\models"
mkdir "%BASE_DIR%\shared\constants"
mkdir "%BASE_DIR%\shared\widgets\inputs"
mkdir "%BASE_DIR%\shared\widgets\cards"
mkdir "%BASE_DIR%\shared\widgets\quiz"
mkdir "%BASE_DIR%\shared\widgets\study"
mkdir "%BASE_DIR%\shared\widgets\labels"
mkdir "%BASE_DIR%\features\auth\screens"
mkdir "%BASE_DIR%\features\auth\repository"
mkdir "%BASE_DIR%\features\flashcard\screens"
mkdir "%BASE_DIR%\features\flashcard\repository"
mkdir "%BASE_DIR%\features\folder\screens"
mkdir "%BASE_DIR%\features\home\tabs"
mkdir "%BASE_DIR%\features\library"
mkdir "%BASE_DIR%\features\module\screens"
mkdir "%BASE_DIR%\features\module\repository"
mkdir "%BASE_DIR%\features\profile"
mkdir "%BASE_DIR%\features\quiz"
mkdir "%BASE_DIR%\features\study"
mkdir "%BASE_DIR%\features\vocabulary\screens"
mkdir "%BASE_DIR%\features\vocabulary\cubit"
mkdir "%BASE_DIR%\features\vocabulary\repository"
mkdir "%BASE_DIR%\features\vocabulary\widgets"

:: Di chuyển file vào vị trí mới
move "%BASE_DIR%\config\app_colors.dart" "%BASE_DIR%\config\"
move "%BASE_DIR%\config\app_config.dart" "%BASE_DIR%\config\"
move "%BASE_DIR%\config\app_theme.dart" "%BASE_DIR%\config\"

move "%BASE_DIR%\core\routes\app_routes.dart" "%BASE_DIR%\core\routes\"
move "%BASE_DIR%\core\api\*.dart" "%BASE_DIR%\core\api\"
move "%BASE_DIR%\core\utils\*.dart" "%BASE_DIR%\core\utils\"

move "%BASE_DIR%\models\user.dart" "%BASE_DIR%\models\"
move "%BASE_DIR%\features\vocabulary\data\flashcard.dart" "%BASE_DIR%\models\"
move "%BASE_DIR%\features\vocabulary\data\study_option.dart" "%BASE_DIR%\models\vocabulary.dart"

move "%BASE_DIR%\shared\constants\strings.dart" "%BASE_DIR%\shared\constants\"

move "%BASE_DIR%\shared\widgets\buttons\qlz_button.dart" "%BASE_DIR%\shared\widgets\inputs\"
move "%BASE_DIR%\shared\widgets\fields\qlz_text_field.dart" "%BASE_DIR%\shared\widgets\inputs\"
move "%BASE_DIR%\shared\widgets\layout\qlz_card.dart" "%BASE_DIR%\shared\widgets\cards\"
move "%BASE_DIR%\shared\widgets\quiz\qlz_quiz_option.dart" "%BASE_DIR%\shared\widgets\quiz\"
move "%BASE_DIR%\shared\widgets\study\qlz_flashcard.dart" "%BASE_DIR%\shared\widgets\study\"
move "%BASE_DIR%\shared\widgets\label\qlz_label.dart" "%BASE_DIR%\shared\widgets\labels\"

move "%BASE_DIR%\features\auth\forgot_password_screen.dart" "%BASE_DIR%\features\auth\screens\"
move "%BASE_DIR%\features\auth\register_screen.dart" "%BASE_DIR%\features\auth\screens\"
move "%BASE_DIR%\features\auth\login_screen.dart" "%BASE_DIR%\features\auth\screens\"

move "%BASE_DIR%\features\flashcard\flashcard_study_mode_screen.dart" "%BASE_DIR%\features\flashcard\screens\"

move "%BASE_DIR%\features\folder\create_folder_screen.dart" "%BASE_DIR%\features\folder\screens\"
move "%BASE_DIR%\features\folder\folder_detail_screen.dart" "%BASE_DIR%\features\folder\screens\"

move "%BASE_DIR%\features\home\home_screen.dart" "%BASE_DIR%\features\home\"
move "%BASE_DIR%\features\home\tabs\home_tab.dart" "%BASE_DIR%\features\home\tabs\"
move "%BASE_DIR%\features\home\tabs\solutions_tab.dart" "%BASE_DIR%\features\home\tabs\"

move "%BASE_DIR%\features\library\library_screen.dart" "%BASE_DIR%\features\library\"

move "%BASE_DIR%\features\module\list_study_module_of_folder_screen.dart" "%BASE_DIR%\features\module\screens\"
move "%BASE_DIR%\features\module\module_settings_screen.dart" "%BASE_DIR%\features\module\screens\"
move "%BASE_DIR%\features\module\create_study_module_screen.dart" "%BASE_DIR%\features\module\screens\"
move "%BASE_DIR%\features\module\module_detail_screen.dart" "%BASE_DIR%\features\module\screens\"

move "%BASE_DIR%\features\profile\profile_screen.dart" "%BASE_DIR%\features\profile\"

move "%BASE_DIR%\features\quiz\quiz_screen.dart" "%BASE_DIR%\features\quiz\"

move "%BASE_DIR%\features\study\flashcard_screen.dart" "%BASE_DIR%\features\study\"

move "%BASE_DIR%\features\vocabulary\screens\vocabulary_screen.dart" "%BASE_DIR%\features\vocabulary\screens\"
move "%BASE_DIR%\features\vocabulary\cubit\vocabulary_cubit.dart" "%BASE_DIR%\features\vocabulary\cubit\"
move "%BASE_DIR%\features\vocabulary\cubit\vocabulary_state.dart" "%BASE_DIR%\features\vocabulary\cubit\"
move "%BASE_DIR%\features\vocabulary\widgets\term_list.dart" "%BASE_DIR%\features\vocabulary\widgets\"
move "%BASE_DIR%\features\vocabulary\widgets\study_progress.dart" "%BASE_DIR%\features\vocabulary\widgets\"
move "%BASE_DIR%\features\vocabulary\widgets\study_options_list.dart" "%BASE_DIR%\features\vocabulary\widgets\"
move "%BASE_DIR%\features\vocabulary\widgets\module_user_info.dart" "%BASE_DIR%\features\vocabulary\widgets\"
move "%BASE_DIR%\features\vocabulary\widgets\flashcard_carousel.dart" "%BASE_DIR%\features\vocabulary\widgets\"

move "%BASE_DIR%\features\welcome_screen.dart" "%BASE_DIR%\features\"

:: Hiển thị thông báo khi script chạy xong
echo.
echo =========================
echo  ✅ Restructure Completed!
echo  📂 Các thư mục và file đã được di chuyển đúng vị trí.
echo =========================
pause
