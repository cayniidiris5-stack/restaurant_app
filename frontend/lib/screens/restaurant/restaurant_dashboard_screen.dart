// ignore_for_file: deprecated_member_use, unused_import, curly_braces_in_flow_control_structures, unnecessary_underscores, use_build_context_synchronously
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/meal_provider.dart';
import '../../models/order_model.dart';
import '../admin/add_meal_screen.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});
  @override
  State<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  void _refresh() {
    final auth = context.read<AuthProvider>();
    context.read<OrderProvider>().fetchAllOrders(auth.token);
    context.read<MealProvider>().fetchMeals();
    context.read<MealProvider>().fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrderProvider>().allOrders;
    final pending = orders.where((o) => !o.isDelivered).length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Restaurant Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          Text('Welcome, ${auth.user?.name ?? ""}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
        ]),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor: isDark ? AppColors.darkText : AppColors.lightText,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _refresh),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(icon: const Icon(Icons.dashboard_rounded), text: 'Overview'),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Text('Orders'),
                if (pending > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                    child: Text('$pending', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ]),
            ),
            const Tab(icon: Icon(Icons.restaurant_menu_rounded), text: 'Menu'),
            const Tab(icon: Icon(Icons.person_rounded), text: 'Profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _OverviewTab(isDark: isDark),
          _OrdersTab(isDark: isDark, token: auth.token),
          _MenuTab(isDark: isDark, token: auth.token),
          _ProfileTab(isDark: isDark),
        ],
      ),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final bool isDark;
  const _OverviewTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().allOrders;
    final meals = context.watch<MealProvider>().meals;
    final pending = orders.where((o) => !o.isDelivered).length;
    final delivered = orders.where((o) => o.isDelivered).length;
    final revenue = orders.where((o) => o.isPaid).fold(0.0, (s, o) => s + o.totalPrice);

    final stats = [
      {'label': 'Total Orders', 'value': '${orders.length}', 'icon': Icons.receipt_long_rounded, 'color': AppColors.primary},
      {'label': 'Pending', 'value': '$pending', 'icon': Icons.hourglass_top_rounded, 'color': AppColors.warning},
      {'label': 'Delivered', 'value': '$delivered', 'icon': Icons.local_shipping_rounded, 'color': AppColors.success},
      {'label': 'Menu Items', 'value': '${meals.length}', 'icon': Icons.restaurant_menu_rounded, 'color': const Color(0xFF7B1FA2)},
      {'label': 'Revenue', 'value': '\$${revenue.toStringAsFixed(2)}', 'icon': Icons.attach_money_rounded, 'color': const Color(0xFF00897B)},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Dashboard Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.lightText)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4),
          itemCount: stats.length,
          itemBuilder: (_, i) {
            final s = stats[i];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: (s['color'] as Color).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: Icon(s['icon'] as IconData, color: s['color'] as Color, size: 20),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s['value'] as String, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: s['color'] as Color)),
                  Text(s['label'] as String, style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
                ]),
              ]),
            );
          },
        ),
        const SizedBox(height: 20),
        if (orders.isNotEmpty) ...[
          Text('Recent Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.lightText)),
          const SizedBox(height: 10),
          ...orders.take(3).map((o) => _OrderMiniCard(order: o, isDark: isDark)),
        ],
      ]),
    );
  }
}

class _OrderMiniCard extends StatelessWidget {
  final OrderModel order;
  final bool isDark;
  const _OrderMiniCard({required this.order, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = order.isDelivered ? AppColors.success : order.isPaid ? AppColors.warning : AppColors.error;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.receipt_rounded, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(order.userName.isNotEmpty ? order.userName : 'Customer', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.lightText)),
          Text(order.orderItems.map((i) => '${i.name} x${i.qty}').join(', '), style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        Text('\$${order.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
      ]),
    );
  }
}

// ── Orders Tab ────────────────────────────────────────────────────────────────
class _OrdersTab extends StatefulWidget {
  final bool isDark;
  final String token;
  const _OrdersTab({required this.isDark, required this.token});
  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> with SingleTickerProviderStateMixin {
  late TabController _sub;
  @override
  void initState() { super.initState(); _sub = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _sub.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().allOrders;
    final pending = orders.where((o) => !o.isDelivered).toList();
    final done = orders.where((o) => o.isDelivered).toList();

    return Column(children: [
      Container(
        color: widget.isDark ? AppColors.darkSurface : AppColors.lightSurface,
        child: TabBar(
          controller: _sub,
          labelColor: AppColors.primary,
          unselectedLabelColor: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
          indicatorColor: AppColors.primary,
          tabs: [Tab(text: 'Pending (${pending.length})'), Tab(text: 'Completed (${done.length})')],
        ),
      ),
      Expanded(child: TabBarView(controller: _sub, children: [
        _buildList(pending),
        _buildList(done),
      ])),
    ]);
  }

  Widget _buildList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => context.read<OrderProvider>().fetchAllOrders(widget.token),
        color: AppColors.primary,
        child: ListView(children: [
          const SizedBox(height: 200),
          Center(child: Column(children: [
            Icon(Icons.inbox_rounded, size: 60, color: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
            const SizedBox(height: 12),
            Text('No orders here', style: TextStyle(color: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
          ])),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => context.read<OrderProvider>().fetchAllOrders(widget.token),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (_, i) => _OrderCard(order: orders[i], isDark: widget.isDark, token: widget.token),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isDark;
  final String token;
  const _OrderCard({required this.order, required this.isDark, required this.token});

  @override
  Widget build(BuildContext context) {
    final statusColor = order.isDelivered ? AppColors.success : order.isPaid ? AppColors.warning : AppColors.error;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(children: [
            Expanded(child: Text('Order #${order.id.substring(order.id.length - 6).toUpperCase()}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? AppColors.darkText : AppColors.lightText))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(order.status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
            ),
          ]),
        ),
        // Customer info
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : const Color(0xFFFFF8F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            _InfoRow(icon: Icons.person_outline_rounded, text: order.userName.isNotEmpty ? order.userName : 'Unknown', isDark: isDark),
            const Divider(height: 10, thickness: 0.5),
            _InfoRow(icon: Icons.phone_outlined, text: order.phoneNumber.isNotEmpty ? order.phoneNumber : 'Not provided', isDark: isDark),
            const Divider(height: 10, thickness: 0.5),
            _InfoRow(icon: Icons.location_on_outlined, text: order.location.isNotEmpty ? order.location : 'Not provided', isDark: isDark),
          ]),
        ),
        // Items
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Items Ordered:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? AppColors.darkText : AppColors.lightText)),
              const SizedBox(height: 6),
              ...order.orderItems.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${item.name}  ×${item.qty}', style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkText : AppColors.lightText))),
                  Text('\$${(item.price * item.qty).toStringAsFixed(2)}', style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
                ]),
              )),
            ],
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Divider(height: 20)),
        // Footer
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total', style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
              Text('\$${order.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
            ]),
            const Spacer(),
            if (!order.isDelivered)
              ElevatedButton.icon(
                onPressed: () async {
                  final ok = await context.read<OrderProvider>().markAsDelivered(order.id, token);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ok ? 'Marked as delivered!' : 'Failed'), backgroundColor: ok ? AppColors.success : AppColors.error));
                },
                icon: const Icon(Icons.local_shipping_rounded, size: 16),
                label: const Text('Mark Delivered'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
          ]),
        ),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  const _InfoRow({required this.icon, required this.text, required this.isDark});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 16, color: AppColors.primary),
    const SizedBox(width: 8),
    Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkText : AppColors.lightText), overflow: TextOverflow.ellipsis)),
  ]);
}

// ── Menu Tab ──────────────────────────────────────────────────────────────────
class _MenuTab extends StatefulWidget {
  final bool isDark;
  final String token;
  const _MenuTab({required this.isDark, required this.token});
  @override
  State<_MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<_MenuTab> {
  String _selectedCat = 'All';

  @override
  Widget build(BuildContext context) {
    final mealProv = context.watch<MealProvider>();
    final allMeals = mealProv.meals;
    final cats = ['All', ...mealProv.dbCategories];
    final filtered = _selectedCat == 'All' ? allMeals : allMeals.where((m) => m.category == _selectedCat).toList();

    return Column(children: [
      // Add item + Add category buttons
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddMealScreen()))
                .then((_) => mealProv.fetchMeals()),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () => _showAddCategoryDialog(context),
            icon: const Icon(Icons.category_rounded, size: 18),
            label: const Text('Category'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ]),
      ),
      // Category filter chips
      SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final c = cats[i];
            final selected = c == _selectedCat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCat = c),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : (widget.isDark ? AppColors.darkCard : AppColors.lightCard),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? AppColors.primary : (widget.isDark ? AppColors.darkDivider : AppColors.lightDivider)),
                ),
                child: Text(c, style: TextStyle(color: selected ? Colors.white : (widget.isDark ? AppColors.darkText : AppColors.lightText), fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
              ),
            );
          },
        ),
      ),
      // Meals list
      Expanded(
        child: mealProv.loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : filtered.isEmpty
                ? Center(child: Text('No items in this category', style: TextStyle(color: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final meal = filtered[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                        ),
                        child: Row(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              imageUrl: meal.fullImageUrl,
                              width: 60, height: 60, fit: BoxFit.cover,
                              placeholder: (_, __) => Container(width: 60, height: 60, color: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.restaurant, color: AppColors.primary)),
                              errorWidget: (_, __, ___) => Container(width: 60, height: 60, color: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.restaurant, color: AppColors.primary)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(meal.name, style: TextStyle(fontWeight: FontWeight.bold, color: widget.isDark ? AppColors.darkText : AppColors.lightText)),
                            const SizedBox(height: 2),
                            Text(meal.category, style: TextStyle(fontSize: 11, color: AppColors.primary)),
                            Text('\$${meal.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15)),
                          ])),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                            onPressed: () async {
                              final ok = await mealProv.deleteMeal(meal.id, widget.token);
                              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(ok ? 'Item removed' : 'Failed'), backgroundColor: ok ? AppColors.success : AppColors.error));
                            },
                          ),
                        ]),
                      );
                    },
                  ),
      ),
    ]);
  }

  void _showAddCategoryDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('New Category', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. Soups, Juices, Desserts...',
            prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              final ok = await context.read<MealProvider>().addCategory(name, widget.token);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(ok ? 'Category "$name" added!' : 'Category exists or failed'), backgroundColor: ok ? AppColors.success : AppColors.error));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// ── Profile Tab ───────────────────────────────────────────────────────────────
class _ProfileTab extends StatefulWidget {
  final bool isDark;
  const _ProfileTab({required this.isDark});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  bool _updating = false;

  Future<void> _pickAndUploadImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _updating = true);
      final bytes = await picked.readAsBytes();
      final auth = context.read<AuthProvider>();
      final ok = await auth.updateProfileImage(bytes, picked.name);
      if (mounted) {
        setState(() => _updating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Profile picture updated successfully!' : 'Failed to update profile picture'),
          backgroundColor: ok ? AppColors.success : AppColors.error,
        ));
      }
    }
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Upload Profile Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadImage(context, ImageSource.camera);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 32),
                          SizedBox(height: 8),
                          Text('Camera', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickAndUploadImage(context, ImageSource.gallery);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_library_rounded, color: AppColors.primary, size: 32),
                          SizedBox(height: 8),
                          Text('Gallery', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isDark = widget.isDark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)],
                ),
                child: CircleAvatar(
                  radius: 65,
                  backgroundColor: isDark ? AppColors.darkCard : Colors.grey[200],
                  backgroundImage: user?.fullImageUrl != null && user!.fullImageUrl.isNotEmpty
                      ? CachedNetworkImageProvider(user.fullImageUrl)
                      : null,
                  child: _updating
                      ? const CircularProgressIndicator(color: AppColors.primary)
                      : (user?.fullImageUrl == null || user!.fullImageUrl.isEmpty)
                          ? Text(
                              user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'R',
                              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary),
                            )
                          : null,
                ),
              ),
              if (!_updating)
                GestureDetector(
                  onTap: () => _showImageSourceDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            user?.name ?? 'Restaurant Name',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.lightText),
          ),
          const SizedBox(height: 4),
          const Text('Partner Restaurant', style: TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            ),
            child: Column(
              children: [
                _ProfileInfoTile(icon: Icons.person_outline_rounded, label: 'Name', value: user?.name ?? '', isDark: isDark),
                const Divider(height: 24),
                _ProfileInfoTile(icon: Icons.email_outlined, label: 'Email Address', value: user?.email ?? '', isDark: isDark),
                const Divider(height: 24),
                _ProfileInfoTile(icon: Icons.shield_outlined, label: 'Account Role', value: 'Restaurant Partner', isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await auth.logout();
                      },
                      child: const Text('Logout', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error.withOpacity(0.1),
                foregroundColor: AppColors.error,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  const _ProfileInfoTile({required this.icon, required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.lightText)),
            ],
          ),
        ),
      ],
    );
  }
}
