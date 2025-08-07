class SaleItem {
  /// Optional identifier for the item in the sale.
  final String? id;

  /// Display name for the item.
  final String name;

  /// Quantity of the item sold.
  final int quantity;

  /// Unit price of the item.
  final double price;

  /// Type of item: "Tamale", "Beverage" or "Combo".
  final String type;

  SaleItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.type,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      type: json['type']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'type': type,
    };
  }
}

