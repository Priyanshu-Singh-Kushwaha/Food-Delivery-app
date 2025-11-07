import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

class FavoriteProvider with ChangeNotifier {
  List<Product> _favoriteItems = [];
  final FirestoreService _firestoreService;

  FavoriteProvider(this._firestoreService) {
    _firestoreService.getFavoriteItemsStream().listen((favoriteProducts) {
      _favoriteItems = favoriteProducts;
      notifyListeners();
    });
  }

  List<Product> get items {
    return [..._favoriteItems];
  }

  bool isFavorite(Product product) {
    return _favoriteItems.any((item) => item.id == product.id);
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      _firestoreService.removeFavoriteItem(product.id);
    } else {
      _firestoreService.addFavoriteItem(product);
    }
  }
}
