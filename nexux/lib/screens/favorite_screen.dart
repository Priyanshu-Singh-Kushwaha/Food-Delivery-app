import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';
import '../providers/cart_provider.dart';
import '../services/firestore_service.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = Provider.of<FavoriteProvider>(context);
    final cart = Provider.of<CartProvider>(context, listen: false);
    final firestoreService = Provider.of<FirestoreService>(context);

    if (firestoreService.userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Favorites')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Favorites'),
      ),
      body: favorites.items.isEmpty
          ? const Center(
              child: Text('No favorite items yet. Start adding some!'),
            )
          : ListView.builder(
              itemCount: favorites.items.length,
              itemBuilder: (ctx, i) {
                final product = favorites.items[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(product.imageUrl),
                        onBackgroundImageError: (exception, stackTrace) {
                          print('Error loading image for favorite item: $exception');
                        },
                      ),
                      title: Text(product.name),
                      subtitle: Text('₹${product.price.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.shopping_cart),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              cart.addItem(product);
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} added to cart!'),
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    onPressed: () {
                                      cart.removeSingleItem(product.id);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite),
                            color: Theme.of(context).colorScheme.error,
                            onPressed: () {
                              favorites.toggleFavorite(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} removed from favorites.'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
