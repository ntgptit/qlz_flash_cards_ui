// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/auth/logic/cubit/auth_cubit.dart';
import 'package:qlz_flash_cards_ui/features/auth/logic/states/auth_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

final class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final errors = state is AuthError ? state.errors : <String, String?>{};

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
                    onSubmitted: (_) => _handleSubmit(context),
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
                    onPressed: isLoading ? null : () => _handleSubmit(context),
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
      },
    );
  }

  void _handleSubmit(BuildContext context) {
    context.read<AuthCubit>().login(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }
}
