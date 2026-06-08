// ignore_for_file: unnecessary_underscores, deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_colors.dart';
import '../../constants/api_constants.dart';
import '../../providers/meal_provider.dart';
import '../../providers/cart_provider.dart';
import '../meal/meal_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mealProv = context.watch<MealProvider>();
    final cart = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favs = mealProv.favorites;

    if (favs.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.favorite_border, size: 70, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
          const SizedBox(height: 12),
          Text('No favorites yet', style: TextStyle(fontSize: 16, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
          const SizedBox(height: 6),
          Text('Tap ❤️ on a meal to save it here', style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext, fontSize: 13)),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favs.length,
      itemBuilder: (ctx, i) {
        final meal = favs[i];
        final inCart = cart.isInCart(meal.id);
        return GestureDetector(
          onTap: () => Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, a, __) => MealDetailScreen(meal: meal),
            transitionsBuilder: (ctx, anim, secAnim, child) => SlideTransition(
              position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
              child: child,
            ),
          )),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: meal.fullImageUrl,
                    width: 90, height: 90, fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(width: 90, height: 90, color: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.restaurant, color: AppColors.primary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meal.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? AppColors.darkText : AppColors.lightText)),
                      const SizedBox(height: 4),
                      Text(meal.category, style: const TextStyle(color: AppColors.lightSubtext, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('\$${meal.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => mealProv.toggleFavorite(meal),
                        child: const Icon(Icons.favorite, color: Colors.red, size: 22),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          if (inCart) { cart.removeFromCart(meal.id); } else { cart.addToCart(meal); }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 32, height: 32,
                          decoration: BoxDecoration(color: inCart ? AppColors.success : AppColors.primary, shape: BoxShape.circle),
                          child: Icon(inCart ? Icons.check : Icons.add, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
