class CartItem {
  final int? id;
  final int itemId;
  final String? code;
  final String? name;
  final double? price;
  final int quantity;

  CartItem({
    this.id,
    required this.itemId,
    this.code,
    this.name,
    this.price,
    required this.quantity,
  });

  // Convert CartItem instance to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_id': itemId,
      'quantity': quantity,
    };
  }

  // Create CartItem instance from Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      itemId: map['item_id'],
      code: map['code'],
      name: map['name'],
      price: map['price']?.toDouble(),
      quantity: map['quantity'],
    );
  }

  // Create copy of CartItem with optional new values
  CartItem copyWith({
    int? id,
    int? itemId,
    String? code,
    String? name,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      code: code ?? this.code,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}