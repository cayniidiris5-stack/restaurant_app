// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});
  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn) context.read<OrderProvider>().fetchMyOrders(auth.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!auth.isLoggedIn) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.lock_outline, size: 60, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
        const SizedBox(height: 12),
        Text('Login to view your orders', style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
      ]));
    }

    if (orderProv.loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    final orders = orderProv.myOrders;
    if (orders.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.receipt_long_outlined, size: 60, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
        const SizedBox(height: 12),
        Text('No orders yet', style: TextStyle(fontSize: 16, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
      ]));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => orderProv.fetchMyOrders(auth.token),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (ctx, i) => _OrderCard(order: orders[i], isDark: isDark, token: auth.token),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isDark;
  final String token;
  const _OrderCard({required this.order, required this.isDark, required this.token});

  Color get _statusColor {
    if (order.isDelivered) return AppColors.success;
    if (order.isPaid) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Order #${order.id.substring(order.id.length - 6).toUpperCase()}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.lightText))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(order.status, style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${order.orderItems.length} item(s)', style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext, fontSize: 13)),
          const SizedBox(height: 4),
          Text(order.orderItems.map((i) => '${i.name} x${i.qty}').join(', '),
              style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${order.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
              if (!order.isPaid)
                ElevatedButton(
                  onPressed: () async {
                    final ok = await context.read<OrderProvider>().markAsPaid(order.id, token);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok ? 'Payment confirmed!' : 'Failed to update'),
                        backgroundColor: ok ? AppColors.success : AppColors.error,
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), elevation: 0),
                  child: const Text('Pay Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
