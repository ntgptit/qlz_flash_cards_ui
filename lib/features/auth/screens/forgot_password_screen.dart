// lib/features/auth/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';

final class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _emailError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final email = _emailController.text.trim();

    // Validate email
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Vui lòng nhập email';
      });
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _emailError = 'Email không hợp lệ';
      });
      return;
    }

    setState(() {
      _emailError = null;
      _isSubmitting = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link đặt lại mật khẩu đã được gửi đến email của bạn'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Quên mật khẩu',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                error: _emailError,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                isRequired: true,
                onSubmitted: (_) => _handleSubmit(),
              ),
              const SizedBox(height: 24),
              QlzButton(
                label: 'Gửi link đặt lại mật khẩu',
                onPressed: _handleSubmit,
                isFullWidth: true,
                isLoading: _isSubmitting,
                variant: QlzButtonVariant.primary,
                size: QlzButtonSize.medium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
