// lib/features/auth/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';

final class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // Validate form
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool isValid = true;

    // Validate email
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Vui lòng nhập email';
      });
      isValid = false;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _emailError = 'Email không hợp lệ';
      });
      isValid = false;
    } else {
      setState(() {
        _emailError = null;
      });
    }

    // Validate password
    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Vui lòng nhập mật khẩu';
      });
      isValid = false;
    } else if (password.length < 6) {
      setState(() {
        _passwordError = 'Mật khẩu phải có ít nhất 6 ký tự';
      });
      isValid = false;
    } else {
      setState(() {
        _passwordError = null;
      });
    }

    if (!isValid) return;

    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      // Navigate to home
      Navigator.pushReplacementNamed(context, AppRoutes.home);
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
          'Đăng nhập',
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
              QlzTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                error: _emailError,
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
                error: _passwordError,
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
                    foregroundColor: Colors.blue,
                  ),
                  child: const Text('Quên mật khẩu?'),
                ),
              ),
              const SizedBox(height: 24),
              QlzButton(
                label: 'Đăng nhập',
                onPressed: _handleSubmit,
                isFullWidth: true,
                isLoading: _isSubmitting,
                variant: QlzButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
