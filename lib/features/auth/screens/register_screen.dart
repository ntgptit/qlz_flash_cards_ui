// lib/features/auth/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/features/auth/logic/cubit/auth_cubit.dart';
import 'package:qlz_flash_cards_ui/features/auth/logic/states/auth_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

final class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
                    onSubmitted: (_) => _handleSubmit(context),
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
      },
    );
  }

  void _handleSubmit(BuildContext context) {
    context.read<AuthCubit>().register(
          _displayNameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
          _confirmPasswordController.text,
        );
  }
}
