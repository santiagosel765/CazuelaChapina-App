class Branch {
  final int? id;
  final String name;
  final String address;
  final String manager;

  Branch({this.id, required this.name, required this.address, required this.manager});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      manager: json['manager']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'address': address,
      'manager': manager,
    };
  }
}
