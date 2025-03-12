// lib/features/auth/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/auth/logic/cubit/auth_cubit.dart';
import 'package:qlz_flash_cards_ui/features/auth/logic/states/auth_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_snackbar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

final class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          QlzSnackbar.success(
            context: context,
            message: 'Link đặt lại mật khẩu đã được gửi đến email của bạn',
          );
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final errors = state is AuthError ? state.errors : <String, String?>{};

        return Scaffold(
          backgroundColor: AppColors.darkBackground,
          appBar: const QlzAppBar(
            title: 'Quên mật khẩu',
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Nhập email của bạn để nhận link đặt lại mật khẩu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  QlzTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Nhập email của bạn',
                    prefixIcon: Icons.email_outlined,
                    error: errors['email'],
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    isRequired: true,
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
                    label: 'Gửi link đặt lại mật khẩu',
                    onPressed: isLoading ? null : () => _handleSubmit(context),
                    isFullWidth: true,
                    isLoading: isLoading,
                    variant: QlzButtonVariant.primary,
                    size: QlzButtonSize.medium,
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
    context.read<AuthCubit>().forgotPassword(_emailController.text.trim());
  }
}
