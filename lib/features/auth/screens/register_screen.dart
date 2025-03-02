// lib/features/auth/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/core/routes/app_routes.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/inputs/qlz_text_field.dart';

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

  String? _displayNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // Validate form
    final displayName = _displayNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    bool isValid = true;

    // Validate display name
    if (displayName.isEmpty) {
      setState(() {
        _displayNameError = 'Vui lòng nhập tên hiển thị';
      });
      isValid = false;
    } else {
      setState(() {
        _displayNameError = null;
      });
    }

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

    // Validate confirm password
    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Vui lòng xác nhận mật khẩu';
      });
      isValid = false;
    } else if (confirmPassword != password) {
      setState(() {
        _confirmPasswordError = 'Mật khẩu xác nhận không khớp';
      });
      isValid = false;
    } else {
      setState(() {
        _confirmPasswordError = null;
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
          'Đăng ký',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
                error: _displayNameError,
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
                error: _confirmPasswordError,
                textInputAction: TextInputAction.done,
                isRequired: true,
                hintText: '',
                onSubmitted: (_) => _handleSubmit(),
              ),
              const SizedBox(height: 24),
              QlzButton(
                label: 'Đăng ký',
                onPressed: _handleSubmit,
                isFullWidth: true,
                isLoading: _isSubmitting,
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
                      foregroundColor: Colors.blue,
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
}
