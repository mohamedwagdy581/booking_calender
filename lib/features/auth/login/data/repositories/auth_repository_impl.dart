import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient supabaseClient;

  AuthRepositoryImpl({required this.supabaseClient});

  @override
  User? getCurrentUser() {
    return supabaseClient.auth.currentUser;
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      // You can handle specific auth errors here if needed
      if (kDebugMode) {
        print('Auth Error on Sign In: ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Error on Sign In: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error on Sign Out: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    try {
      await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('Auth Error on Sign Up: ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Error on Sign Up: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('Auth Error on Password Reset: ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('Error on Password Reset: $e');
      }
      rethrow;
    }
  }

  @override
  Stream<AuthState> get authStateChanges => supabaseClient.auth.onAuthStateChange;
}
