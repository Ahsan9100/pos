class UserModel {
  final String id;
  final String? name;
  final String? email;

  UserModel({required this.id, this.name, this.email});

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      name: map['name'] as String?,
      email: map['email'] as String?,
    );
  }
}
