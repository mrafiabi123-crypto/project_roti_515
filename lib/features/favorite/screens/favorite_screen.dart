import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../widgets/favorite_app_bar.dart';
import '../widgets/favorite_grid.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Stack(
        children: [
          const FavoriteGrid(),
          const FavoriteAppBar(),
        ],
      ),
    );
  }
}