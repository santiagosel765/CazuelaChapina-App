import 'catalog_item.dart';

class Tamale {
  final int id;
  final String tamaleType;
  final String filling;
  final String wrapper;
  final String spiceLevel;
  final double price;

  Tamale({
    required this.id,
    required this.tamaleType,
    required this.filling,
    required this.wrapper,
    required this.spiceLevel,
    required this.price,
  });

  factory Tamale.fromJson(Map<String, dynamic> json) {
    return Tamale(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      tamaleType: json['tamaleType']?.toString() ?? '',
      filling: json['filling']?.toString() ?? '',
      wrapper: json['wrapper']?.toString() ?? '',
      spiceLevel: json['spiceLevel']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tamaleType': tamaleType,
      'filling': filling,
      'wrapper': wrapper,
      'spiceLevel': spiceLevel,
      'price': price,
    };
  }
}
