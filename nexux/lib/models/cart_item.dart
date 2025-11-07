import 'product.dart';

class CartItem {
  final String? id;
  final Product product;
  int quantity;

  CartItem({this.id, required this.product, this.quantity = 1});

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        product: Product.fromJson(json['product']),
        quantity: json['quantity'],
      );
}
