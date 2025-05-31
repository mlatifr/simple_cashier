class Product {
  final int? id;
  final String code;
  final String name;
  final double price;
  final int stock;

  Product({
    this.id,
    required this.code,
    required this.name,
    required this.price,
    required this.stock,
  });

  // Convert Product instance to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'price': price,
      'stock': stock,
    };
  }

  // Create Product instance from Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      code: map['code'],
      name: map['name'],
      price: map['price'],
      stock: map['stock'],
    );
  }

  // Create copy of Product with optional new values
  Product copyWith({
    int? id,
    String? code,
    String? name,
    double? price,
    int? stock,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
    );
  }
}
