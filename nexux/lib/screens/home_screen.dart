import 'package:flutter/material.dart';
import 'package:nexux/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Product> _allProducts = [
    Product(id: 'p1', name: 'Margherita Pizza', imageUrl: 'assets/images/pizza.png', price: 250.0, description: 'Classic Margherita with fresh basil and mozzarella.', restaurant: 'Pizza Palace'),
    Product(id: 'p2', name: 'Chicken Burger', imageUrl: 'assets/images/burger.png', price: 180.0, description: 'Juicy chicken patty with lettuce and tomato.', restaurant: 'Burger King'),
    Product(id: 'p3', name: 'Sushi Combo', imageUrl: 'assets/images/sushi.png', price: 750.0, description: 'Assorted fresh sushi pieces.', restaurant: 'Sakura Sushi'),
    Product(id: 'p4', name: 'Veggie Wrap', imageUrl: 'assets/images/wrap.png', price: 120.0, description: 'Healthy wrap with fresh vegetables.', restaurant: 'Green Bites Cafe'),
    Product(id: 'p5', name: 'Pasta Alfredo', imageUrl: 'assets/images/pasta.png', price: 320.0, description: 'Creamy Alfredo pasta with mushrooms.', restaurant: 'Pasta House'),
    Product(id: 'p6', name: 'Espresso', imageUrl: 'assets/images/coffee.png', price: 90.0, description: 'Strong and aromatic espresso.', restaurant: 'Coffee Corner'),
    Product(id: 'p7', name: 'Tandoori Chicken', imageUrl: 'assets/images/tandoori.png', price: 450.0, description: 'Spicy and smoky Tandoori chicken.', restaurant: 'Spice Route'),
    Product(id: 'p8', name: 'Chocolate Brownie', imageUrl: 'assets/images/brownie.png', price: 150.0, description: 'Rich and fudgy chocolate brownie.', restaurant: 'Sweet Delights'),
  ];

  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredProducts = _allProducts;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        return product.name.toLowerCase().contains(query) ||
               product.restaurant.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search v2...', 
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.4), width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.4), width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2.0),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.tertiary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.error),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged();
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
            cursorColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        toolbarHeight: 80,
      ),
      body: _filteredProducts.isEmpty
          ? const Center(
              child: Text(
                'No results found.',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (ctx, i) => ProductItem(product: _filteredProducts[i]),
            ),
    );
  }
}


class ProductItem extends StatelessWidget {
  final Product product;
  const ProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final favorites = Provider.of<FavoriteProvider>(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: product.id,
            child: Image.asset(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          color: Colors.grey[600],
                        ),
                        Text("Image not found", style: TextStyle(color: Colors.grey[600]))
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                          stops: [0.0, 0.5]
                        )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 2.0,
                                        color: Colors.black.withOpacity(0.5),
                                        offset: Offset(1, 1),
                                      )
                                    ]
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.restaurant,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontStyle: FontStyle.italic,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${product.price.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4.0,
                                        color: Colors.black.withOpacity(0.7),
                                        offset: Offset(1, 1),
                                      )
                                    ]
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      border: Border(
                        top: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.5),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            favorites.isFavorite(product) ? Icons.favorite : Icons.favorite_border,
                            color: favorites.isFavorite(product) ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.tertiary,
                            size: 26,
                          ),
                          onPressed: () {
                            favorites.toggleFavorite(product);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(favorites.isFavorite(product) ? '${product.name} added to favorites!' : '${product.name} removed from favorites.'),
                                duration: const Duration(seconds: 1),
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.shopping_cart,
                            size: 26,
                          ),
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
                                  textColor: Theme.of(context).colorScheme.secondary,
                                ),
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}