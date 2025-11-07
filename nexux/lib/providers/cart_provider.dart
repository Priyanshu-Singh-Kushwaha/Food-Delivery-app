import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};
  final FirestoreService _firestoreService;

  CartProvider(this._firestoreService) {
    _firestoreService.getCartItemsStream().listen((cartItems) {
      _items = Map.fromIterable(
        cartItems,
        key: (item) => item.product.id,
        value: (item) => item,
      );
      notifyListeners();
    });
  }

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      final existingItem = _items[product.id]!;
      _firestoreService.updateCartItemQuantity(product.id, existingItem.quantity + 1);
    } else {
      _firestoreService.addCartItem(CartItem(product: product, quantity: 1));
    }
  }

  void removeItem(String productId) {
    _firestoreService.removeCartItem(productId);
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      final existingItem = _items[productId]!;
      _firestoreService.updateCartItemQuantity(productId, existingItem.quantity - 1);
    } else {
      _firestoreService.removeCartItem(productId);
    }
  }

  Future<void> clearCart() async {
    await _firestoreService.clearCartItems();
  }
}
