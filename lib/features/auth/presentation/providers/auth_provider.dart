import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qlz_flash_cards_ui/core/providers/app_providers.dart';
import 'package:qlz_flash_cards_ui/core/utils/validation_utils.dart';
import 'package:qlz_flash_cards_ui/features/auth/data/repositories/auth_repository.dart';
import 'package:qlz_flash_cards_ui/features/auth/domain/states/auth_state.dart';

// Định nghĩa Provider cho AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

// StateNotifier thay thế cho AuthCubit
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthStateNotifier(this._repository) : super(const AuthInitial());

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    final Map<String, String?> errors = {};

    final emailError = ValidationUtils.validateEmail(email);
    if (emailError != null) {
      errors['email'] = emailError;
    }

    final passwordError = ValidationUtils.validatePassword(password);
    if (passwordError != null) {
      errors['password'] = passwordError;
    }

    if (errors.isNotEmpty) {
      state = AuthError(errors);
      return;
    }

    try {
      await _repository.login(email, password);
      state = const AuthSuccess();
    } catch (e) {
      errors['general'] = e.toString();
      state = AuthError(errors);
    }
  }

  Future<void> register(String displayName, String email, String password,
      String confirmPassword) async {
    state = const AuthLoading();
    final Map<String, String?> errors = {};

    final displayNameError = ValidationUtils.validateDisplayName(displayName);
    if (displayNameError != null) {
      errors['displayName'] = displayNameError;
    }

    final emailError = ValidationUtils.validateEmail(email);
    if (emailError != null) {
      errors['email'] = emailError;
    }

    final passwordError = ValidationUtils.validatePassword(password);
    if (passwordError != null) {
      errors['password'] = passwordError;
    }

    final confirmPasswordError =
        ValidationUtils.validateConfirmPassword(password, confirmPassword);
    if (confirmPasswordError != null) {
      errors['confirmPassword'] = confirmPasswordError;
    }

    if (errors.isNotEmpty) {
      state = AuthError(errors);
      return;
    }

    try {
      await _repository.register(displayName, email, password);
      state = const AuthSuccess();
    } catch (e) {
      errors['general'] = e.toString();
      state = AuthError(errors);
    }
  }

  Future<void> forgotPassword(String email) async {
    state = const AuthLoading();
    final Map<String, String?> errors = {};

    final emailError = ValidationUtils.validateEmail(email);
    if (emailError != null) {
      errors['email'] = emailError;
      state = AuthError(errors);
      return;
    }

    try {
      await _repository.forgotPassword(email);
      state = const AuthSuccess();
    } catch (e) {
      errors['general'] = e.toString();
      state = AuthError(errors);
    }
  }

  void reset() {
    state = const AuthInitial();
  }
}

// Provider chính cho quản lý state auth
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(repository);
});
