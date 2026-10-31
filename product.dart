class Product {
  final int? id;
  final String name;
  final int stock;
  final double clientPrice;
  final double collaboratorPrice;
  final int minStock;

  Product({
    this.id,
    required this.name,
    required this.stock,
    required this.clientPrice,
    required this.collaboratorPrice,
    required this.minStock,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'stock': stock,
      'clientPrice': clientPrice,
      'collaboratorPrice': collaboratorPrice,
      'minStock': minStock,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      stock: map['stock'],
      clientPrice: map['clientPrice'],
      collaboratorPrice: map['collaboratorPrice'],
      minStock: map['minStock'],
    );
  }
}
