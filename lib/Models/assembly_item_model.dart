class AssemblyItem {
  final int id;
  final int productId;
  final int ingredientId;
  final double quantity;
  final String unit;

  AssemblyItem(
      {required this.id,
      required this.productId,
      required this.ingredientId,
      required this.quantity,
      required this.unit});

  factory AssemblyItem.fromMap(Map<String, dynamic> map) {
    return AssemblyItem(
      id: map['id'],
      productId: map['product_id'],
      ingredientId: map['ingredient_id'],
      quantity: map['quantity'],
      unit: map['unit'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'ingredient_id': ingredientId,
      'quantity': quantity,
      'unit': unit,
    };
  }
}
