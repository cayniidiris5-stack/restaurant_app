// ignore_for_file: unnecessary_underscores, deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_colors.dart';
import '../../constants/api_constants.dart';
import '../../providers/meal_provider.dart';
import '../../providers/cart_provider.dart';
import '../meal/meal_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final mealProv = context.watch<MealProvider>();
    final cart = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = mealProv.categories.where((c) => c != 'All').toList();
    final filtered = _selectedCategory == null
        ? mealProv.meals
        : mealProv.meals.where((m) => m.category == _selectedCategory).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Explore by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.lightText)),
          ),
        ),
        // Category horizontal chips
        SliverToBoxAdapter(
          child: SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _CategoryChip(label: 'All', selected: _selectedCategory == null, onTap: () => setState(() => _selectedCategory = null), isDark: isDark),
                ...categories.map((cat) => _CategoryChip(label: cat, selected: _selectedCategory == cat, onTap: () => setState(() => _selectedCategory = cat), isDark: isDark)),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        if (mealProv.loading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
        else if (filtered.isEmpty)
          SliverFillRemaining(child: Center(child: Text('No meals in this category', style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext))))
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final meal = filtered[i];
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
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: meal.fullImageUrl,
                            width: 80, height: 80, fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(width: 80, height: 80, color: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.restaurant, color: AppColors.primary)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(meal.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.lightText)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                child: Text(meal.category, style: const TextStyle(color: AppColors.primary, fontSize: 11)),
                              ),
                              const SizedBox(height: 4),
                              Text('\$${meal.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () { if (inCart) { cart.removeFromCart(meal.id); } else { cart.addToCart(meal); } },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: inCart ? AppColors.success : AppColors.primary, shape: BoxShape.circle),
                            child: Icon(inCart ? Icons.check : Icons.add, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: filtered.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;
  const _CategoryChip({required this.label, required this.selected, required this.onTap, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : (isDark ? AppColors.darkDivider : AppColors.lightDivider)),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : (isDark ? AppColors.darkText : AppColors.lightText), fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
      ),
    );
  }
}
