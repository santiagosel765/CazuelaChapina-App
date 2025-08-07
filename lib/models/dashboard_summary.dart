import 'package:flutter/foundation.dart';

class DashboardSummary {
  final Sales sales;
  final List<TamalSales> topTamales;
  final PopularBeverages popularBeverages;
  final SpiceLevel spiceLevel;
  final Profit profit;
  final Waste waste;

  DashboardSummary({
    required this.sales,
    required this.topTamales,
    required this.popularBeverages,
    required this.spiceLevel,
    required this.profit,
    required this.waste,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      sales: Sales.fromJson(json['sales'] ?? {}),
      topTamales: (json['topTamales'] as List<dynamic>? ?? [])
          .map((e) => TamalSales.fromJson(e as Map<String, dynamic>))
          .toList(),
      popularBeverages:
          PopularBeverages.fromJson(json['popularBeverages'] ?? {}),
      spiceLevel: SpiceLevel.fromJson(json['spiceLevel'] ?? {}),
      profit: Profit.fromJson(json['profit'] ?? {}),
      waste: Waste.fromJson(json['waste'] ?? {}),
    );
  }
}

class Sales {
  final num day;
  final num month;

  Sales({required this.day, required this.month});

  factory Sales.fromJson(Map<String, dynamic> json) {
    return Sales(
      day: json['day'] is num
          ? json['day'] as num
          : double.tryParse(json['day']?.toString() ?? '') ?? 0,
      month: json['month'] is num
          ? json['month'] as num
          : double.tryParse(json['month']?.toString() ?? '') ?? 0,
    );
  }
}

class TamalSales {
  final int id;
  final String name;
  final int quantity;

  TamalSales({required this.id, required this.name, required this.quantity});

  factory TamalSales.fromJson(Map<String, dynamic> json) {
    return TamalSales(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
    );
  }
}

class Beverage {
  final String name;
  final int quantity;

  Beverage({required this.name, required this.quantity});

  factory Beverage.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Beverage(name: '', quantity: 0);
    }
    return Beverage(
      name: json['name']?.toString() ?? '',
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
    );
  }

  bool get isEmpty => name.isEmpty;
}

class PopularBeverages {
  final Beverage? morning;
  final Beverage? afternoon;
  final Beverage? night;

  PopularBeverages({this.morning, this.afternoon, this.night});

  factory PopularBeverages.fromJson(Map<String, dynamic> json) {
    return PopularBeverages(
      morning: json['morning'] != null
          ? Beverage.fromJson(json['morning'] as Map<String, dynamic>)
          : null,
      afternoon: json['afternoon'] != null
          ? Beverage.fromJson(json['afternoon'] as Map<String, dynamic>)
          : null,
      night: json['night'] != null
          ? Beverage.fromJson(json['night'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SpiceLevel {
  final int spicy;
  final int nonSpicy;

  SpiceLevel({required this.spicy, required this.nonSpicy});

  factory SpiceLevel.fromJson(Map<String, dynamic> json) {
    return SpiceLevel(
      spicy: json['spicy'] is int
          ? json['spicy'] as int
          : int.tryParse(json['spicy']?.toString() ?? '') ?? 0,
      nonSpicy: json['nonSpicy'] is int
          ? json['nonSpicy'] as int
          : int.tryParse(json['nonSpicy']?.toString() ?? '') ?? 0,
    );
  }
}

class Profit {
  final num tamales;
  final num beverages;
  final num combos;

  Profit({required this.tamales, required this.beverages, required this.combos});

  factory Profit.fromJson(Map<String, dynamic> json) {
    return Profit(
      tamales: (json['tamales'] as num?) ?? 0,
      beverages: (json['beverages'] as num?) ?? 0,
      combos: (json['combos'] as num?) ?? 0,
    );
  }
}

class Waste {
  final num quantity;
  final num cost;

  Waste({required this.quantity, required this.cost});

  factory Waste.fromJson(Map<String, dynamic> json) {
    return Waste(
      quantity: (json['quantity'] as num?) ?? 0,
      cost: (json['cost'] as num?) ?? 0,
    );
  }
}
