import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/auth/domain/states/auth_state.dart';
import 'package:qlz_flash_cards_ui/features/auth/presentation/providers/auth_provider.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

final class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Xử lý chuyển hướng khi đăng ký thành công
    ref.listen<AuthState>(authStateProvider, (previous, current) {
      if (current is AuthSuccess) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });

    final isLoading = authState is AuthLoading;
    final errors =
        authState is AuthError ? authState.errors : <String, String?>{};

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const QlzAppBar(
        title: 'Đăng ký',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              QlzTextField(
                label: 'Tên hiển thị',
                controller: _displayNameController,
                prefixIcon: Icons.person_outline,
                error: errors['displayName'],
                textInputAction: TextInputAction.next,
                isRequired: true,
                hintText: '',
              ),
              const SizedBox(height: 16),
              QlzTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                error: errors['email'],
                textInputAction: TextInputAction.next,
                isRequired: true,
                hintText: '',
              ),
              const SizedBox(height: 16),
              QlzTextField(
                label: 'Mật khẩu',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                error: errors['password'],
                textInputAction: TextInputAction.next,
                isRequired: true,
                hintText: '',
              ),
              const SizedBox(height: 16),
              QlzTextField(
                label: 'Xác nhận mật khẩu',
                controller: _confirmPasswordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline,
                error: errors['confirmPassword'],
                textInputAction: TextInputAction.done,
                isRequired: true,
                hintText: '',
                onSubmitted: (_) => _handleSubmit(),
              ),
              if (errors.containsKey('general'))
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errors['general'] ?? '',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              const SizedBox(height: 24),
              QlzButton(
                label: 'Đăng ký',
                onPressed: isLoading ? null : () => _handleSubmit(),
                isFullWidth: true,
                isLoading: isLoading,
                variant: QlzButtonVariant.primary,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Đã có tài khoản? ',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.login,
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('Đăng nhập'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    ref.read(authStateProvider.notifier).register(
          _displayNameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          _confirmPasswordController.text,
        );
  }
}
