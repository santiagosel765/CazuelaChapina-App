enum Season { spring, summer, autumn, winter }

Season seasonFromString(String value) {
  return Season.values.firstWhere(
    (e) => e.name == value,
    orElse: () => Season.spring,
  );
}

class ComboProduct {
  final int id;
  final String name;
  final double price;
  final int quantity;

  ComboProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory ComboProduct.fromJson(Map<String, dynamic> json) {
    return ComboProduct(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

class Combo {
  final int? id;
  final String name;
  final String description;
  final double price;
  final bool isActive;
  final bool isEditable;
  final Season season;
  final List<ComboProduct> tamales;
  final List<ComboProduct> beverages;

  Combo({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isActive,
    required this.isEditable,
    required this.season,
    required this.tamales,
    required this.beverages,
  });

  double get total {
    final t = tamales.fold<double>(0, (p, e) => p + e.price * e.quantity);
    final b =
        beverages.fold<double>(0, (p, e) => p + e.price * e.quantity);
    return t + b;
  }

  factory Combo.fromJson(Map<String, dynamic> json) {
    return Combo(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      isEditable: json['isEditable'] as bool? ?? true,
      season: seasonFromString(json['season']?.toString() ?? 'spring'),
      tamales: (json['tamales'] as List<dynamic>? ?? [])
          .map((e) => ComboProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
      beverages: (json['beverages'] as List<dynamic>? ?? [])
          .map((e) => ComboProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'price': price,
      'isActive': isActive,
      'isEditable': isEditable,
      'season': season.name,
      'tamales': tamales.map((e) => e.toJson()).toList(),
      'beverages': beverages.map((e) => e.toJson()).toList(),
    };
  }
}
