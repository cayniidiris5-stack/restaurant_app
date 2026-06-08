// ignore_for_file: deprecated_member_use, unnecessary_underscores, unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_colors.dart';
import '../../constants/api_constants.dart';
import '../../providers/cart_provider.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor: isDark ? AppColors.darkText : AppColors.lightText,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Clear Cart'),
                  content: const Text('Remove all items from cart?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(onPressed: () { cart.clearCart(); Navigator.pop(context); }, child: const Text('Clear', style: TextStyle(color: AppColors.error))),
                  ],
                ),
              ),
              child: const Text('Clear', style: TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                  const SizedBox(height: 16),
                  Text('Your cart is empty', style: TextStyle(fontSize: 18, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
                  const SizedBox(height: 8),
                  Text('Add some delicious meals!', style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                final item = cart.items[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                          imageUrl: item.meal.fullImageUrl,
                          width: 70, height: 70, fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(width: 70, height: 70, color: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.restaurant, color: AppColors.primary)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.meal.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? AppColors.darkText : AppColors.lightText), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('\$${item.meal.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => cart.decreaseQty(item.meal.id),
                            child: Container(width: 30, height: 30, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), shape: BoxShape.circle), child: const Icon(Icons.remove, color: AppColors.primary, size: 16)),
                          ),
                          const SizedBox(width: 10),
                          Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => cart.increaseQty(item.meal.id),
                            child: Container(width: 30, height: 30, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 16)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: isDark ? AppColors.darkSurface : AppColors.lightSurface, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${cart.itemCount} item(s)', style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
                        Text('Total: \$${cart.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (_, a, __) => const CheckoutScreen(),
                          transitionsBuilder: (ctx, anim, secAnim, child) => SlideTransition(
                            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                            child: child,
                          ),
                        )),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                        child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
