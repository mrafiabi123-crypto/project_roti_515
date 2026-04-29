import 'package:roti_515/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoginBackButton extends StatelessWidget {
  const LoginBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: context.colors.surface.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: Offset(0, 1),
            )
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: context.colors.textDark,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
