// lib/features/auth/logic/cubit/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qlz_flash_cards_ui/core/utils/validation_utils.dart';
import 'package:qlz_flash_cards_ui/features/auth/data/repositories/auth_repository.dart';
import 'package:qlz_flash_cards_ui/features/auth/logic/states/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthInitial());

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());

    // Validate form
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
      emit(AuthError(errors));
      return;
    }

    try {
      await _repository.login(email, password);
      emit(const AuthSuccess());
    } catch (e) {
      errors['general'] = e.toString();
      emit(AuthError(errors));
    }
  }

  Future<void> register(String displayName, String email, String password,
      String confirmPassword) async {
    emit(const AuthLoading());

    // Validate form
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
      emit(AuthError(errors));
      return;
    }

    try {
      await _repository.register(displayName, email, password);
      emit(const AuthSuccess());
    } catch (e) {
      errors['general'] = e.toString();
      emit(AuthError(errors));
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(const AuthLoading());

    // Validate form
    final Map<String, String?> errors = {};

    final emailError = ValidationUtils.validateEmail(email);
    if (emailError != null) {
      errors['email'] = emailError;
      emit(AuthError(errors));
      return;
    }

    try {
      await _repository.forgotPassword(email);
      emit(const AuthSuccess());
    } catch (e) {
      errors['general'] = e.toString();
      emit(AuthError(errors));
    }
  }

  void reset() {
    emit(const AuthInitial());
  }
}
