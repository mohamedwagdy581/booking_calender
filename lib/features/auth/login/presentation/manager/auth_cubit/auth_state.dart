import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  final String? message;
  final bool isPasswordObscured;

  const Unauthenticated({
    this.message,
    this.isPasswordObscured = true, // Default to obscured
  });

  Unauthenticated copyWith({
    String? message,
    bool? isPasswordObscured,
  }) {
    return Unauthenticated(
      message: message ?? this.message,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
    );
  }

  @override
  List<Object?> get props => [message, isPasswordObscured];
}
