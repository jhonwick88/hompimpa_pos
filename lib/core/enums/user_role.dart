
enum UserRole {
  dev,
  admin,
  user
}

UserRole userRoleFromString(String value) {
  switch (value.toLowerCase()) {
    case 'dev':
      return UserRole.dev;
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.user;
  }
}

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.dev:
        return 'dev';
      case UserRole.admin:
        return 'admin';
      case UserRole.user:
        return 'user';
    }
  }
}
