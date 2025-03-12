// lib/core/utils/validation_utils.dart
class ValidationUtils {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool doPasswordsMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Vui lòng nhập email';
    } else if (!isValidEmail(email)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    } else if (!isValidPassword(password)) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  static String? validateConfirmPassword(
      String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    } else if (!doPasswordsMatch(password, confirmPassword)) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  static String? validateDisplayName(String displayName) {
    if (displayName.isEmpty) {
      return 'Vui lòng nhập tên hiển thị';
    }
    return null;
  }
}
