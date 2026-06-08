// ignore_for_file: deprecated_member_use, unnecessary_underscores, unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_colors.dart';
import '../../constants/api_constants.dart';
import '../../providers/meal_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/meal_model.dart';
import '../meal/meal_detail_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final mealProv = context.watch<MealProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => mealProv.fetchMeals(),
      child: CustomScrollView(
        slivers: [
          // ── Banner ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              height: 160,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -10,
                    child: Icon(Icons.fastfood_rounded, size: 130, color: Colors.white.withOpacity(0.15)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Delicious Somali', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text('Food Hub 🍽️', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: const Text('Order Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Category Filter ─────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: mealProv.categories.length,
                itemBuilder: (ctx, i) {
                  final cat = mealProv.categories[i];
                  final selected = mealProv.selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => mealProv.setCategory(cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : (isDark ? AppColors.darkCard : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: selected ? AppColors.primary : (isDark ? AppColors.darkDivider : AppColors.lightDivider)),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: selected ? Colors.white : (isDark ? AppColors.darkText : AppColors.lightText),
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ── Section Title ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Popular Meals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Meal Grid ────────────────────────────────────────────
          if (mealProv.loading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
          else if (mealProv.error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 60, color: AppColors.lightSubtext),
                    const SizedBox(height: 12),
                    Text(mealProv.error!, style: const TextStyle(color: AppColors.lightSubtext)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: mealProv.fetchMeals, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('Retry', style: TextStyle(color: Colors.white))),
                  ],
                ),
              ),
            )
          else if (mealProv.filteredMeals.isEmpty)
            const SliverFillRemaining(child: Center(child: Text('No meals found', style: TextStyle(color: AppColors.lightSubtext))))
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _MealCard(meal: mealProv.filteredMeals[i]),
                  childCount: mealProv.filteredMeals.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealModel meal;
  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inCart = cart.isInCart(meal.id);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, a, __) => MealDetailScreen(meal: meal),
        transitionsBuilder: (ctx, anim, secAnim, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      )),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.25 : 0.07), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: CachedNetworkImage(
                  imageUrl: meal.fullImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => Container(
                    color: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
                    child: const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
                    child: const Icon(Icons.restaurant, size: 48, color: AppColors.primary),
                  ),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppColors.darkText : AppColors.lightText), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(meal.category, style: const TextStyle(fontSize: 11, color: AppColors.lightSubtext), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${meal.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                      GestureDetector(
                        onTap: () {
                          if (inCart) {
                            cart.removeFromCart(meal.id);
                          } else {
                            cart.addToCart(meal);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${meal.name} added to cart'), duration: const Duration(seconds: 1), backgroundColor: AppColors.success),
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: inCart ? AppColors.success : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(inCart ? Icons.check : Icons.add, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
