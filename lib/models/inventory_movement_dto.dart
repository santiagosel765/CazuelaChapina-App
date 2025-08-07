class InventoryMovementDto {
  final double quantity;
  final String reason;

  InventoryMovementDto({required this.quantity, required this.reason});

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'reason': reason,
    };
  }
}
