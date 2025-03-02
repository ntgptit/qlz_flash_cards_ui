// lib/features/welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';

final class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar circle image
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/auth_avatar.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Main text
              const Text(
                'Cách tốt nhất để học. Đăng ký miễn phí.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Terms text
              Text(
                'Bằng việc đăng ký, bạn chấp nhận Điều khoản dịch vụ và Chính sách quyền riêng tư của Quizlet',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Google Sign In Button
              _buildGoogleButton(),
              const SizedBox(height: 16),

              // Email Sign Up Button
              _buildEmailButton(context),
              const SizedBox(height: 24),

              // Sign In Link
              _buildSignInLink(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Builder(
      builder: (context) => QlzButton(
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
      ),
    );
  }

  Widget _buildEmailButton(BuildContext context) {
    return QlzButton.secondary(
      label: 'Đăng ký bằng email',
      icon: Icons.email_outlined,
      onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
      isFullWidth: true,
      size: QlzButtonSize.large,
    );
  }

  Widget _buildSignInLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Đã có tài khoản? ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
          child: const Text(
            'Đăng nhập',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
