import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/user_profile.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/food_analysis_result.dart';

String? __app_id;
String? __firebase_config;
String? __initial_auth_token;

class FirestoreService with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  String? _userId;
  String _appId = 'default-app-id';

  String? get userId => _userId;
  String get appId => _appId;

  FirestoreService() {
    _appId = __app_id ?? 'default-app-id';
    print('FirestoreService: Initialized with App ID: $_appId');

    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _userId = user.uid;
        print('FirestoreService: Authenticated user ID from stream: $_userId');
      } else {
        _handleAuthInitialization();
      }
      notifyListeners();
    });

    if (_auth.currentUser != null) {
      _userId = _auth.currentUser!.uid;
      print('FirestoreService: Current authenticated user ID (initial check): $_userId');
    } else {
      _handleAuthInitialization();
    }
  }

  Future<void> _handleAuthInitialization() async {
    if (__initial_auth_token != null) {
      await _signInWithCustomToken(__initial_auth_token!);
    } else {
      await _signInAnonymously();
    }
    if (_userId == null) {
      _userId = _uuid.v4();
      print('FirestoreService: Fallback to random ID as no auth or token available: $_userId');
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      _userId = userCredential.user?.uid;
      print('FirestoreService: Signed in anonymously. User ID: $_userId');
    } catch (e) {
      print('FirestoreService: Error signing in anonymously: $e');
      _userId = _uuid.v4();
      print('FirestoreService: Fallback to random ID after anonymous sign-in failure: $_userId');
    }
    notifyListeners();
  }

  Future<void> _signInWithCustomToken(String token) async {
    try {
      UserCredential userCredential = await _auth.signInWithCustomToken(token);
      _userId = userCredential.user?.uid;
      print('FirestoreService: Signed in with custom token. User ID: $_userId');
    } catch (e) {
      print('FirestoreService: Error signing in with custom token: $e');
      _userId = _uuid.v4();
      print('FirestoreService: Fallback to random ID after custom token sign-in failure: $_userId');
    }
    notifyListeners();
  }


  CollectionReference<Map<String, dynamic>> _getUserCollectionRef(String collectionPath) {
    if (_userId == null) {
      _userId = _uuid.v4();
      print('FirestoreService: WARNING: _userId was null when _getUserCollectionRef called, generating new random ID: $_userId');
    }
    return _db.collection('artifacts').doc(_appId).collection('users').doc(_userId!).collection(collectionPath);
  }

  DocumentReference<Map<String, dynamic>> _getUserDocumentRef(String collectionPath, String docId) {
    if (_userId == null) {
      _userId = _uuid.v4();
      print('FirestoreService: WARNING: _userId was null when _getUserDocumentRef called, generating new random ID: $_userId');
    }
    return _db.collection('artifacts').doc(_appId).collection('users').doc(_userId!).collection(collectionPath).doc(docId);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    if (_userId == null) {
      print('FirestoreService: Cannot save user profile, userId is null.');
      return;
    }
    try {
      await _db.collection('artifacts').doc(_appId).collection('users').doc(_userId!).collection('profile').doc('user_data').set(profile.toJson(), SetOptions(merge: true));
      print('User profile saved to Firestore for user: $_userId.');
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  Stream<UserProfile?> getUserProfileStream() {
    if (_userId == null) {
      print('FirestoreService: User ID is null, returning empty UserProfile stream.');
      return Stream.value(null);
    }
    return _db.collection('artifacts').doc(_appId).collection('users').doc(_userId!).collection('profile').doc('user_data').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserProfile.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  Stream<List<CartItem>> getCartItemsStream() {
    if (_userId == null) {
      print('FirestoreService: User ID is null, returning empty CartItem stream.');
      return Stream.value([]);
    }
    return _getUserCollectionRef('cart_items').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CartItem.fromJson(doc.data()..['id'] = doc.id)).toList();
    });
  }

  Future<void> addCartItem(CartItem item) async {
    if (_userId == null) {
      print('FirestoreService: Cannot add cart item, userId is null.');
      return;
    }
    try {
      await _getUserCollectionRef('cart_items').doc(item.product.id).set(item.toJson());
      print('Cart item added/updated: ${item.product.name} for user: $_userId');
    } catch (e) {
      print('Error adding/updating cart item: $e');
    }
  }

  Future<void> removeCartItem(String productId) async {
    if (_userId == null) {
      print('FirestoreService: Cannot remove cart item, userId is null.');
      return;
    }
    try {
      await _getUserDocumentRef('cart_items', productId).delete();
      print('Cart item removed: $productId for user: $_userId');
    } catch (e) {
      print('Error removing cart item: $e');
    }
  }

  Future<void> updateCartItemQuantity(String productId, int quantity) async {
    if (_userId == null) {
      print('FirestoreService: Cannot update cart item quantity, userId is null.');
      return;
    }
    try {
      await _getUserDocumentRef('cart_items', productId).update({'quantity': quantity});
      print('Cart item quantity updated for: $productId to $quantity for user: $_userId');
    } catch (e) {
      print('Error updating cart item quantity: $e');
    }
  }

  Future<void> clearCartItems() async {
    if (_userId == null) {
      print('FirestoreService: Cannot clear cart items, userId is null.');
      return;
    }
    try {
      final batch = _db.batch();
      final snapshot = await _getUserCollectionRef('cart_items').get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('All cart items cleared.');
    } catch (e) {
      print('Error clearing cart items: $e');
    }
  }

  Stream<List<Product>> getFavoriteItemsStream() {
    if (_userId == null) {
      print('FirestoreService: User ID is null, returning empty FavoriteItem stream.');
      return Stream.value([]);
    }
    return _getUserCollectionRef('favorite_items').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromJson(doc.data()..['id'] = doc.id)).toList();
    });
  }

  Future<void> addFavoriteItem(Product product) async {
    if (_userId == null) {
      print('FirestoreService: Cannot add favorite item, userId is null.');
      return;
    }
    try {
      await _getUserCollectionRef('favorite_items').doc(product.id).set(product.toJson());
      print('Favorite item added: ${product.name} for user: $_userId');
    } catch (e) {
      print('Error adding favorite item: $e');
    }
  }

  Future<void> removeFavoriteItem(String productId) async {
    if (_userId == null) {
      print('FirestoreService: Cannot remove favorite item, userId is null.');
      return;
    }
    try {
      await _getUserDocumentRef('favorite_items', productId).delete();
      print('Favorite item removed: $productId for user: $_userId');
    } catch (e) {
      print('Error removing favorite item: $e');
    }
  }

  Future<void> addFoodAnalysisResult(FoodAnalysisResult result) async {
    if (_userId == null) {
      print('FirestoreService: Cannot add food analysis result, userId is null.');
      return;
    }
    try {
      final docRef = _getUserCollectionRef('food_analyses').doc();
      await docRef.set(result.toJson()..['id'] = docRef.id);
      print('Food analysis result added: ${result.foodName} for user: $_userId');
    } catch (e) {
      print('Error adding food analysis result: $e');
    }
  }

  Stream<List<FoodAnalysisResult>> getFoodAnalysisResultsStream() {
    if (_userId == null) {
      print('FirestoreService: User ID is null, returning empty FoodAnalysisResult stream.');
      return Stream.value([]);
    }
    return _getUserCollectionRef('food_analyses').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FoodAnalysisResult.fromJson(doc.data()..['id'] = doc.id)).toList();
    });
  }
}
