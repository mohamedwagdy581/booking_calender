import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription<supabase.AuthState> _authStateSubscription;

  AuthCubit(this._authRepository) : super(AuthInitial()) {
    _authStateSubscription = _authRepository.authStateChanges.listen((authState) {
      if (authState.event == supabase.AuthChangeEvent.signedIn) {
        emit(Authenticated(authState.session!.user));
      } else if (authState.event == supabase.AuthChangeEvent.signedOut) {
        emit(const Unauthenticated());
      }
    });
  }

  Future<void> checkAuthStatus() async {
    // Add a delay to ensure the splash screen is visible and listeners are ready.
    await Future.delayed(const Duration(seconds: 3)); 
    try {
      final currentUser = _authRepository.getCurrentUser();
      if (currentUser != null) {
        emit(Authenticated(currentUser));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated(message: e.toString()));
    }
  }

  void togglePasswordVisibility() {
    if (state is Unauthenticated) {
      final currentState = state as Unauthenticated;
      emit(currentState.copyWith(isPasswordObscured: !currentState.isPasswordObscured));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      // The stream listener will automatically emit Authenticated state
    } catch (e) {
      emit(Unauthenticated(message: 'Sign in failed: ${e.toString()}'));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    emit(AuthLoading());
    try {
      await _authRepository.sendPasswordResetEmail(email);
      emit(const Unauthenticated(message: 'Password reset email sent. Please check your inbox.'));
    } catch (e) {
      emit(Unauthenticated(message: 'Failed to send email: ${e.toString()}'));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      // The stream listener will automatically emit Unauthenticated state
    } catch (e) {
      emit(Unauthenticated(message: 'Sign out failed: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}
