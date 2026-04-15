import 'package:flutter/material.dart';

/// Utility yang menampilkan animasi gambar produk "terbang" menuju ikon keranjang.
///
/// Cara pakai:
/// ```dart
/// CartFlyAnimation.trigger(
///   context: context,
///   sourceKey: imageKey,      // GlobalKey pada widget gambar produk
///   imageUrl: product.imageUrl,
/// );
/// ```
///
/// Pastikan cart icon di AppBar sudah mendaftarkan key-nya via
/// [CartFlyAnimation.cartIconKey].
class CartFlyAnimation {
  CartFlyAnimation._();

  /// Key yang harus dipasang ke widget cart icon di AppBar.
  static final GlobalKey cartIconKey = GlobalKey();

  /// Trigger animasi terbang.
  static void trigger({
    required BuildContext context,
    required GlobalKey sourceKey,
    required String imageUrl,
  }) {
    final sourceCtx = sourceKey.currentContext;
    if (sourceCtx == null) return;

    final sourceBox = sourceCtx.findRenderObject() as RenderBox?;
    if (sourceBox == null) return;

    // Posisi gambar produk di layar
    final sourceOffset = sourceBox.localToGlobal(Offset.zero);
    final sourceSize = sourceBox.size;

    // Posisi target (cart icon)
    Offset targetOffset = Offset(
      MediaQuery.of(context).size.width - 40,
      MediaQuery.of(context).padding.top + 65,
    );
    final cartCtx = cartIconKey.currentContext;
    if (cartCtx != null) {
      final cartBox = cartCtx.findRenderObject() as RenderBox?;
      if (cartBox != null) {
        final pos = cartBox.localToGlobal(Offset.zero);
        targetOffset = Offset(
          pos.dx + cartBox.size.width / 2,
          pos.dy + cartBox.size.height / 2,
        );
      }
    }

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _FlyParticle(
        startOffset: Offset(
          sourceOffset.dx + sourceSize.width / 2 - 30,
          sourceOffset.dy + sourceSize.height / 2 - 30,
        ),
        endOffset: targetOffset,
        imageUrl: imageUrl,
        onComplete: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );

    overlay.insert(entry);
  }
}

// ── Widget animasi partikel terbang ──────────────────────────────────────────

class _FlyParticle extends StatefulWidget {
  final Offset startOffset;
  final Offset endOffset;
  final String imageUrl;
  final VoidCallback onComplete;

  const _FlyParticle({
    required this.startOffset,
    required this.endOffset,
    required this.imageUrl,
    required this.onComplete,
  });

  @override
  State<_FlyParticle> createState() => _FlyParticleState();
}

class _FlyParticleState extends State<_FlyParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Gerakan horizontal maju
  late final Animation<double> _x;
  // Gerakan vertikal dengan lemparan parabola
  late final Animation<double> _y;
  // Mengecil saat mendekati target
  late final Animation<double> _scale;
  // Memudar di akhir
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _x = Tween<double>(
      begin: widget.startOffset.dx,
      end: widget.endOffset.dx,
    ).chain(CurveTween(curve: Curves.easeInCubic)).animate(_ctrl);

    // Buat kurva parabola dengan keyframe: naik dulu lalu turun ke target
    _y = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: widget.startOffset.dy,
          end: widget.startOffset.dy - 80,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: widget.startOffset.dy - 80,
          end: widget.endOffset.dy,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 65,
      ),
    ]).animate(_ctrl);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 0.15)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 80,
      ),
    ]).animate(_ctrl);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_ctrl);

    _ctrl.forward().whenComplete(widget.onComplete);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Positioned(
        left: _x.value,
        top: _y.value,
        child: IgnorePointer(
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B2B),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_cart,
                        color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
