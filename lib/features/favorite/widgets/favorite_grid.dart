import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorite_provider.dart';
import 'favorite_card.dart';
import 'favorite_empty_state.dart';

class FavoriteGrid extends StatelessWidget {
  const FavoriteGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favProvider, child) {
        final favorites = favProvider.favorites;

        if (favorites.isEmpty) {
          return const FavoriteEmptyState();
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.58,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) =>
              FavoriteCard(product: favorites[index]),
        );
      },
    );
  }
}
