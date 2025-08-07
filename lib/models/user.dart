class User {
  final int id;
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String status;
  final int roleId;
  final String role;

  User({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.status,
    required this.roleId,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      fullName: json['fullName']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      roleId: json['roleId'] is int
          ? json['roleId'] as int
          : int.tryParse(json['roleId']?.toString() ?? '') ?? 0,
      role: json['role']?.toString() ?? '',
    );
  }
}
