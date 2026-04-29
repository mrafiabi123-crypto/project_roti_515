import 'package:flutter/material.dart';
import 'package:roti_515/core/theme/app_theme.dart';

class AnimatedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  const AnimatedFavoriteButton({super.key, required this.isFavorite, required this.onTap});

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
      reverseDuration: Duration(milliseconds: 200),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimatedFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: context.colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              if (widget.isFavorite)
                BoxShadow(
                  color: context.colors.error.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
            ],
          ),
          child: Icon(
            widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            color: widget.isFavorite ? context.colors.error : context.colors.textHint,
            size: 16,
          ),
        ),
      ),
    );
  }
}
