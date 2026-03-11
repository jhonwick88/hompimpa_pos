import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hompimpa_pos/features/orders/presentation/cart_controller.dart';

class MobileActionBar extends ConsumerWidget {
  final VoidCallback onCartPressed;
  final VoidCallback onManualOrderPressed;
  final VoidCallback onQuickOrderPressed;

  const MobileActionBar({
    Key? key,
    required this.onCartPressed,
    required this.onManualOrderPressed,
    required this.onQuickOrderPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final cart = cartState.items;
    final cartCount = cart.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart, size: 28),
              onPressed: onCartPressed,
              tooltip: 'Cart',
              padding: const EdgeInsets.all(12),
            ),
            if (cartCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: CartBadge(count: cartCount),
              ),
          ],
        ),
      ],
    );
  }
}

class CartBadge extends StatelessWidget {
  final int count;
  const CartBadge({Key? key, required this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
