class Role {
  final int id;
  final String name;
  final String description;
  final bool isActive;

  Role({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isActive: json['isActive'] == true || json['isActive'] == 'true',
    );
  }
}
