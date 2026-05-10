enum UserRole { admin, manager, cashier }

extension UserRoleX on UserRole {
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.manager:
        return 'manager';
      case UserRole.cashier:
        return 'cashier';
    }
  }

  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.cashier:
        return 'Cashier';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'cashier':
      default:
        return UserRole.cashier;
    }
  }
}

class AppUserModel {
  const AppUserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
  });

  final String uid;
  final String email;
  final UserRole role;
  final String? name;

  bool get isAdmin => role == UserRole.admin;
  bool get isManager => role == UserRole.manager;
  bool get isCashier => role == UserRole.cashier;

  // Role based permissions
  bool get canAccessProducts => true; // Temporarily open for demo
  bool get canAccessSales => true;
  bool get canAccessReports => true;
  bool get canAccessSettings => true;
  bool get canAccessInventory => true;
  bool get canAccessCustomers => true;
  bool get canAccessSuppliers => true;
  bool get canAccessExpenses => true;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role.value,
      'name': name,
    };
  }

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    return AppUserModel(
      uid: (map['uid'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      role: UserRoleX.fromString((map['role'] ?? 'cashier') as String),
      name: map['name'] as String?,
    );
  }
}
