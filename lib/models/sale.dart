import 'sale_item.dart';

class Sale {
  final String? id;
  final DateTime date;
  final double total;
  final String paymentMethod;
  final String user;
  final String branchId;
  final List<SaleItem> items;
  final bool synced;

  Sale({
    this.id,
    required this.date,
    required this.total,
    required this.paymentMethod,
    required this.user,
    required this.branchId,
    required this.items,
    this.synced = true,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id']?.toString(),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      total: (json['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => SaleItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      synced: json['synced'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'date': date.toIso8601String(),
      'total': total,
      'paymentMethod': paymentMethod,
      'user': user,
      'branchId': branchId,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }

  Map<String, dynamic> toLocalJson() {
    return {
      ...toJson(),
      'synced': synced,
    };
  }

  factory Sale.fromLocalJson(Map<String, dynamic> json) => Sale.fromJson(json);
}

