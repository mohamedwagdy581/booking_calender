import 'package:equatable/equatable.dart';

import '../../../../core/utils/display_name.dart';

class Employee extends Equatable {
  const Employee({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.disabled,
    required this.isSelf,
    this.createdAt,
    this.lastSignInAt,
  });

  final String id;
  final String email;
  final String fullName;
  final String role;
  final bool disabled;
  final bool isSelf;
  final DateTime? createdAt;
  final DateTime? lastSignInAt;

  bool get isAdmin => role == 'admin';
  String get displayName => friendlyName(fullName: fullName, email: email);

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'] as String,
        email: json['email'] as String? ?? '',
        fullName: json['full_name'] as String? ?? '',
        role: json['role'] as String? ?? 'staff',
        disabled: json['disabled'] as bool? ?? false,
        isSelf: json['is_self'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
        lastSignInAt:
            DateTime.tryParse(json['last_sign_in_at']?.toString() ?? ''),
      );

  @override
  List<Object?> get props =>
      [id, email, fullName, role, disabled, isSelf, createdAt, lastSignInAt];
}
