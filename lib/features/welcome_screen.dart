import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';

final class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng MediaQuery để responsive
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 600;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  screenSize.height - MediaQuery.of(context).padding.vertical,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar container with semantics for accessibility
                  Semantics(
                    label: 'Profile image',
                    image: true,
                    child: Container(
                      width: isSmallScreen ? 100 : 120,
                      height: isSmallScreen ? 100 : 120,
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
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 32),
                  Text(
                    'Cách tốt nhất để học. Đăng ký miễn phí.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bằng việc đăng ký, bạn chấp nhận Điều khoản dịch vụ và Chính sách quyền riêng tư của Quizlet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.darkTextSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 32 : 40),
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
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return QlzButton(
      label: 'Tiếp tục với Google',
      imageAssetPath: 'assets/icons/google_icon.png',
      imageSize: 24,
      onPressed: () {
        // Implement Google sign-in
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      },
      isFullWidth: true,
      variant: QlzButtonVariant.primary,
      size: QlzButtonSize.large,
      backgroundColor: AppColors.darkCard,
      foregroundColor: AppColors.darkText,
      borderColor: AppColors.darkBorder,
    );
  }

  Widget _buildEmailButton(BuildContext context) {
    return QlzButton.secondary(
      label: 'Đăng ký bằng email',
      icon: Icons.email_outlined,
      onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
      isFullWidth: true,
      size: QlzButtonSize.large,
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.primary,
      borderColor: AppColors.primary.withOpacity(0.5),
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
}
