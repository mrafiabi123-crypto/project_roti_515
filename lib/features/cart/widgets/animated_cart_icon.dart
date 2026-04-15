import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/page_transitions.dart';
import '../providers/cart_provider.dart';
import '../screens/cart_screen.dart';

class AnimatedCartIcon extends StatefulWidget {
  final CartProvider cart;
  final Key? iconKey;

  const AnimatedCartIcon({
    super.key,
    required this.cart,
    this.iconKey,
  });

  @override
  State<AnimatedCartIcon> createState() => _AnimatedCartIconState();
}

class _AnimatedCartIconState extends State<AnimatedCartIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeCtrl;
  late Animation<double> _wobble;
  int _prevCount = 0;

  @override
  void initState() {
    super.initState();
    _prevCount = widget.cart.totalItems;

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Animasi goyangan ikon keranjang (kiri-kanan ringan)
    _wobble = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: -0.08)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 20),
      TweenSequenceItem(
          tween: Tween(begin: -0.08, end: 0.08)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 0.08, end: -0.05)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 25),
      TweenSequenceItem(
          tween: Tween(begin: -0.05, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 25),
    ]).animate(_shakeCtrl);
  }

  @override
  void didUpdateWidget(covariant AnimatedCartIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cart.totalItems != _prevCount) {
      _prevCount = widget.cart.totalItems;
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.cart.totalItems;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        FadePageRoute(page: const CartScreen()),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Ikon keranjang dengan goyangan
          AnimatedBuilder(
            animation: _wobble,
            builder: (_, child) => Transform.rotate(
              angle: _wobble.value,
              child: child,
            ),
            child: Container(
              key: widget.iconKey,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  color: AppColors.textBrown, size: 22),
            ),
          ),

          // Badge counter dengan pop animation
          if (count > 0)
            Positioned(
              right: -2,
              top: -2,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: Curves.elasticOut,
                    ),
                    child: child,
                  );
                },
                child: Container(
                  // KEY wajib berubah setiap count berubah supaya
                  // AnimatedSwitcher mendeteksi perubahan widget.
                  key: ValueKey(count),
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
