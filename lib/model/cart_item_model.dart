import 'product_model.dart';

class CartItem {
  final int id;
  final int productId;
  final Product product;
  final int quantity;
  final double price;
  final double totalPrice;
  final DateTime createdAt;

  CartItem({
    required this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.createdAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json, Product product) {
    return CartItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      product: product,
      quantity: json['quantity'] ?? 0,
      price: _parseDouble(json['price']),
      totalPrice: _parseDouble(json['total']),
      createdAt: DateTime.tryParse(json['date_created'] ?? '') ?? DateTime.now(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'price': price,
      'total': totalPrice,
      'date_created': createdAt.toIso8601String(),
    };
  }

  CartItem copyWith({
    int? id,
    int? productId,
    Product? product,
    int? quantity,
    double? price,
    double? totalPrice,
    DateTime? createdAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 