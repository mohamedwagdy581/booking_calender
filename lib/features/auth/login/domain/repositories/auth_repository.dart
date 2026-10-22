import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateDisplayName(String name);

  /// Verifies [currentPassword] before setting [newPassword].
  Future<void> changePassword(
      {required String currentPassword, required String newPassword});
  User? getCurrentUser();
  Stream<AuthState> get authStateChanges;
}
