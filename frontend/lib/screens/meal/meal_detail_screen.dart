// ignore_for_file: unnecessary_underscores, deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_colors.dart';
import '../../constants/api_constants.dart';
import '../../models/meal_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/meal_provider.dart';

class MealDetailScreen extends StatefulWidget {
  final MealModel meal;
  const MealDetailScreen({super.key, required this.meal});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final mealProv = context.watch<MealProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFav = mealProv.isFavorite(widget.meal.id);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isDark ? AppColors.darkCard : Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.primary),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => mealProv.toggleFavorite(widget.meal),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: isDark ? AppColors.darkCard : Colors.white, shape: BoxShape.circle),
                  child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : AppColors.lightSubtext, size: 20),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: widget.meal.fullImageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5), child: const Center(child: CircularProgressIndicator(color: AppColors.primary))),
                errorWidget: (_, __, ___) => Container(color: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5), child: const Icon(Icons.restaurant, size: 80, color: AppColors.primary)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(widget.meal.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.lightText))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                        child: Text(widget.meal.category, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('\$${widget.meal.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 16),
                  Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.lightText)),
                  const SizedBox(height: 8),
                  Text(widget.meal.description, style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext, height: 1.6)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text('Quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.lightText)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () { if (_qty > 1) setState(() => _qty--); },
                        child: Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), shape: BoxShape.circle), child: const Icon(Icons.remove, color: AppColors.primary, size: 20)),
                      ),
                      const SizedBox(width: 16),
                      Text('$_qty', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => setState(() => _qty++),
                        child: Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), shape: BoxShape.circle), child: const Icon(Icons.add, color: AppColors.primary, size: 20)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Total: \$${(widget.meal.price * _qty).toStringAsFixed(2)}', style: TextStyle(fontSize: 15, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: ElevatedButton(
            onPressed: () {
              for (int i = 0; i < _qty; i++) { cart.addToCart(widget.meal); }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$_qty x ${widget.meal.name} added!'), backgroundColor: AppColors.success, duration: const Duration(seconds: 2)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0),
            child: Text('Add to Cart — \$${(widget.meal.price * _qty).toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
