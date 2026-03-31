import 'package:flutter/material.dart';

/// Widget fade-in staggered untuk item di grid produk.
/// Setiap kartu muncul dengan delay berdasarkan [index]-nya.
class ProductFadeAnimation extends StatefulWidget {
  final Widget child;
  final int index;

  const ProductFadeAnimation({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<ProductFadeAnimation> createState() => _ProductFadeAnimationState();
}

class _ProductFadeAnimationState extends State<ProductFadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    Future.delayed(Duration(milliseconds: widget.index * 40), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _fade, child: widget.child);
  }
}
