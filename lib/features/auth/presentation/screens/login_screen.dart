import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/auth/domain/states/auth_state.dart';
import 'package:qlz_flash_cards_ui/features/auth/presentation/providers/auth_provider.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

final class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Xử lý chuyển hướng khi đăng nhập thành công
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
        title: 'Đăng nhập',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                textInputAction: TextInputAction.done,
                isRequired: true,
                hintText: '',
                onSubmitted: (_) => _handleSubmit(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.forgotPassword,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Quên mật khẩu?'),
                ),
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
                label: 'Đăng nhập',
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
                    'Chưa có tài khoản? ',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.register,
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('Đăng ký'),
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
    ref.read(authStateProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }
}
