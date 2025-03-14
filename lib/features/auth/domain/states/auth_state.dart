import 'package:equatable/equatable.dart';

// Có thể giữ Equatable hoặc chuyển sang Freezed nếu dự án sử dụng Freezed
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  const AuthSuccess();
}

class AuthError extends AuthState {
  final Map<String, String?> errors;

  const AuthError(this.errors);

  @override
  List<Object?> get props => [errors];
}
