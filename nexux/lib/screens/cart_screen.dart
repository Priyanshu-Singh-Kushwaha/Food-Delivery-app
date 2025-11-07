import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/firestore_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  Future<void> _processPayment(BuildContext context, CartProvider cart) async {
    final String? paymentMethod = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Select Payment Method',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const Divider(height: 30, thickness: 1, color: Colors.white12),
              ListTile(
                leading: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/5/59/Google_Pay_Logo.svg/1200px-Google_Pay_Logo.svg.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.payment, size: 40, color: Colors.blue), // Fallback icon
                ),
                title: Text('Google Pay', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                onTap: () => Navigator.pop(dialogContext, 'Google Pay'),
              ),
              ListTile(
                leading: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/Paytm_logo.png/800px-Paytm_logo.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.payment, size: 40, color: Colors.lightBlue), // Fallback icon
                ),
                title: Text('Paytm', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                onTap: () => Navigator.pop(dialogContext, 'Paytm'),
              ),
              ListTile(
                leading: const Icon(Icons.delivery_dining, size: 40, color: Colors.orange),
                title: Text('Cash on Delivery', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                onTap: () => Navigator.pop(dialogContext, 'Cash on Delivery'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Cancel',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (paymentMethod == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment cancelled.'),
            backgroundColor: Colors.grey[700],
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 20),
              Text(
                'Processing $paymentMethod...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              Text(
                'Please do not close the app.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 3));

    if (context.mounted) {
      Navigator.of(context).pop();
    }
    bool paymentSuccessful = true;

    if (paymentMethod == 'Cash on Delivery') {
      paymentSuccessful = true;
    } else {
      paymentSuccessful = true;
    }

    if (paymentSuccessful) {
      await cart.clearCart();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Successful via $paymentMethod! Your order has been placed.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Failed via $paymentMethod. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final firestoreService = Provider.of<FirestoreService>(context);

    if (firestoreService.userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Cart')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '₹${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  TextButton(
                    onPressed: cart.totalAmount <= 0
                        ? null
                        : () {
                            _processPayment(context, cart);
                          },
                    child: const Text('PROCEED TO PAYMENT'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: cart.items.isEmpty
                ? const Center(
                    child: Text(
                      'Your cart is empty. Start adding some items!',
                      style: TextStyle(fontSize: 18, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final cartItem = cart.items.values.toList()[i];
                      final productId = cart.items.keys.toList()[i];
                      return Dismissible(
                        key: ValueKey(productId),
                        background: Container(
                          color: Theme.of(context).colorScheme.error,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 4,
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) {
                          return showDialog(
                            context: ctx,
                            builder: (dialogCtx) => AlertDialog(
                              title: const Text('Are you sure?'),
                              content: const Text('Do you want to remove the item from the cart?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('No'),
                                  onPressed: () {
                                    Navigator.of(dialogCtx).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: const Text('Yes'),
                                  onPressed: () {
                                    Navigator.of(dialogCtx).pop(true);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          cart.removeItem(productId);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 4,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(cartItem.product.imageUrl),
                                onBackgroundImageError: (exception, stackTrace) {
                                  print('Error loading image for cart item: $exception');
                                },
                              ),
                              title: Text(cartItem.product.name),
                              subtitle: Text('Total: ₹${(cartItem.product.price * cartItem.quantity).toStringAsFixed(2)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      cart.removeSingleItem(productId);
                                    },
                                  ),
                                  Text('${cartItem.quantity}x'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      cart.addItem(cartItem.product);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
