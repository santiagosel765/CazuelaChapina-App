import 'catalog_item.dart';

class Beverage {
  final int id;
  final String beverageType;
  final String size;
  final String sweetener;
  final List<String> toppings;
  final double price;

  Beverage({
    required this.id,
    required this.beverageType,
    required this.size,
    required this.sweetener,
    required this.toppings,
    required this.price,
  });

  factory Beverage.fromJson(Map<String, dynamic> json) {
    return Beverage(
      id: json['id'] as int,
      beverageType: json['beverageType']?.toString() ?? '',
      size: json['size']?.toString() ?? '',
      sweetener: json['sweetener']?.toString() ?? '',
      toppings: (json['toppings'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'beverageType': beverageType,
      'size': size,
      'sweetener': sweetener,
      'toppings': toppings,
      'price': price,
    };
  }
}
