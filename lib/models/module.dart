class Module {
  final int id;
  final String name;

  Module({required this.id, required this.name});

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}
