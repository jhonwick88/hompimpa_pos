import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cart_controller.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

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
            AddToCartIcon(
              key: cartIconKey,
              icon: const Icon(Icons.shopping_cart, size: 28),
            ),
            IconButton(
              icon: const SizedBox.shrink(), // Dummy icon since AddToCartIcon handles it? No, AddToCartIcon just wraps.
              // Actually AddToCartIcon is usually the one that holds the key and needs to be visible.
              // Let's check typical usage. Usually AddToCartIcon(key: cartKey, icon: Icon(...))
              // But we need the IconButton behavior (onPressed).
              onPressed: onCartPressed,
              tooltip: 'Cart',
              padding: const EdgeInsets.all(12),
            ),
            if (cartCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: AnimatedCartBadge(count: cartCount),
              ),
          ],
        ),
      ],
    );
  }
}

final GlobalKey<CartIconKey> cartIconKey = GlobalKey<CartIconKey>();

class AnimatedCartBadge extends StatefulWidget {
  final int count;
  const AnimatedCartBadge({Key? key, required this.count}) : super(key: key);

  @override
  State<AnimatedCartBadge> createState() => _AnimatedCartBadgeState();
}

class _AnimatedCartBadgeState extends State<AnimatedCartBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _colorAnimation = ColorTween(
      begin: Colors.red,
      end: Colors.orange[400],
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));
  }

  @override
  void didUpdateWidget(AnimatedCartBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _controller.isAnimating ? _colorAnimation.value : Colors.red,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            constraints: const BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            child: Text(
              '${widget.count}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
