import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/features/auth/domain/states/auth_state.dart';
import 'package:qlz_flash_cards_ui/features/auth/presentation/providers/auth_provider.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_snackbar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

final class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Xử lý thông báo khi gửi yêu cầu thành công
    ref.listen<AuthState>(authStateProvider, (previous, current) {
      if (current is AuthSuccess) {
        QlzSnackbar.success(
          context: context,
          message: 'Link đặt lại mật khẩu đã được gửi đến email của bạn',
        );
        Navigator.pop(context);
      }
    });

    final isLoading = authState is AuthLoading;
    final errors =
        authState is AuthError ? authState.errors : <String, String?>{};

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
                label: 'Gửi link đặt lại mật khẩu',
                onPressed: isLoading ? null : () => _handleSubmit(),
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
  }

  void _handleSubmit() {
    ref
        .read(authStateProvider.notifier)
        .forgotPassword(_emailController.text.trim());
  }
}
