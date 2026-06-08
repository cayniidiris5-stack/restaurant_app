// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  String _paymentMethod = 'Cash on Delivery';
  bool _placing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login first'), backgroundColor: AppColors.error));
      return;
    }
    setState(() => _placing = true);
    final cart = context.read<CartProvider>();
    final orderProv = context.read<OrderProvider>();
    final success = await orderProv.placeOrder(
      cart.items,
      cart.totalPrice,
      auth.token,
      _phoneController.text.trim(),
      _locationController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _placing = false);
    if (success) {
      cart.clearCart();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 70, height: 70, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle), child: const Icon(Icons.check, color: Colors.white, size: 40)),
              const SizedBox(height: 16),
              const Text('Order Placed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Your order has been placed successfully.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.lightSubtext)),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Navigator.pop(context); Navigator.pop(context); Navigator.pop(context); },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Back to Home', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(orderProv.error ?? 'Failed to place order'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor: isDark ? AppColors.darkText : AppColors.lightText,
        elevation: 0,
        leading: GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Order Summary',
            isDark: isDark,
            child: Column(
              children: [
                ...cart.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(child: Text('${item.meal.name} x${item.quantity}', style: TextStyle(color: isDark ? AppColors.darkText : AppColors.lightText))),
                      Text('\$${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('\$${cart.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: _SectionCard(
              title: 'Delivery Information',
              isDark: isDark,
              child: Column(
                children: [
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(color: isDark ? AppColors.darkText : AppColors.lightText),
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                    ),
                    validator: (v) => v!.isEmpty ? 'Enter your phone number' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationController,
                    keyboardType: TextInputType.streetAddress,
                    style: TextStyle(color: isDark ? AppColors.darkText : AppColors.lightText),
                    decoration: InputDecoration(
                      labelText: 'Delivery Address',
                      prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      filled: true,
                    ),
                    validator: (v) => v!.isEmpty ? 'Enter your delivery address' : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Payment Method',
            isDark: isDark,
            child: Column(
              children: ['Cash on Delivery', 'Online Payment'].map((method) {
                return RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  title: Text(method, style: TextStyle(color: isDark ? AppColors.darkText : AppColors.lightText)),
                  value: method,
                  groupValue: _paymentMethod,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _placing ? null : _placeOrder,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
              child: _placing
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;
  const _SectionCard({required this.title, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? AppColors.darkText : AppColors.lightText)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
