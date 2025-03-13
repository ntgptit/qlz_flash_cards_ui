import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';

final class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool smallScreen = isSmallScreen(context);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAvatar(smallScreen),
                SizedBox(height: smallScreen ? 24 : 32),
                _buildTitleText(context),
                const SizedBox(height: 12),
                _buildSubtitleText(context),
                SizedBox(height: smallScreen ? 32 : 40),
                _buildGoogleButton(context),
                const SizedBox(height: 16),
                _buildEmailButton(context),
                const SizedBox(height: 32),
                _buildSignInLink(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool smallScreen) {
    return Semantics(
      label: 'Profile image',
      image: true,
      child: Container(
        width: smallScreen ? 100 : 120,
        height: smallScreen ? 100 : 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.darkBorder,
            width: 2,
          ),
          image: const DecorationImage(
            image: AssetImage('assets/images/auth_avatar.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleText(BuildContext context) {
    return Text(
      'Cách tốt nhất để học. Đăng ký miễn phí.',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitleText(BuildContext context) {
    return Text(
      'Bằng việc đăng ký, bạn chấp nhận Điều khoản dịch vụ và Chính sách quyền riêng tư của Quizlet',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.darkTextSecondary,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return _buildAuthButton(
      context,
      label: 'Tiếp tục với Google',
      icon: null,
      imagePath: 'assets/icons/google_icon.png',
      onPressed: () =>
          Navigator.of(context).pushReplacementNamed(AppRoutes.home),
      backgroundColor: AppColors.darkCard, // Màu nền trung tính
      foregroundColor: AppColors.darkText, // Màu chữ phù hợp
      borderColor: AppColors.darkBorder.withOpacity(0.5), // Viền nhẹ
    );
  }

  Widget _buildEmailButton(BuildContext context) {
    return _buildAuthButton(
      context,
      label: 'Đăng ký bằng email',
      icon: Icons.email_outlined,
      imagePath: null,
      onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
      backgroundColor: AppColors.primary, // Màu chủ đạo, làm nổi bật
      foregroundColor: Colors.white, // Chữ trắng cho dễ đọc
      borderColor: AppColors.primary, // Viền cùng màu nền
    );
  }

  Widget _buildAuthButton(
    BuildContext context, {
    required String label,
    IconData? icon,
    String? imagePath,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color foregroundColor,
    required Color borderColor,
  }) {
    return QlzButton(
      label: label,
      icon: icon,
      imageAssetPath: imagePath,
      imageSize: 24,
      onPressed: onPressed,
      isFullWidth: true,
      variant: QlzButtonVariant.primary,
      size: QlzButtonSize.large,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
    );
  }

  Widget _buildSignInLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đã có tài khoản? ',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
          ),
          child: const Text('Đăng nhập'),
        ),
      ],
    );
  }

  bool isSmallScreen(BuildContext context) {
    return MediaQuery.sizeOf(context).height < 600;
  }
}
