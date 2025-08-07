class InventoryItem {
  final int id;
  final String name;
  final String type;
  final double stock;
  final double unitCost;
  final bool isCritical;

  InventoryItem({
    required this.id,
    required this.name,
    required this.type,
    required this.stock,
    required this.unitCost,
    required this.isCritical,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      stock: (json['stock'] as num?)?.toDouble() ?? 0,
      unitCost: (json['unitCost'] as num?)?.toDouble() ?? 0,
      isCritical: json['isCritical'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'stock': stock,
      'unitCost': unitCost,
      'isCritical': isCritical,
    };
  }
}
