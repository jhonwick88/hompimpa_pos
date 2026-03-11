
import 'package:hompimpa_pos/core/enums/user_role.dart';

class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final UserRole role;
  final String? storeId;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    required this.role,
    this.storeId,
  });

  factory AppUser.fromMap(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      role: userRoleFromString(data['role'] ?? 'user'),
      storeId: data['storeId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.name,
      'storeId': storeId,
    };
  }
}
