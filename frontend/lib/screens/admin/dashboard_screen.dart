// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/meal_provider.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import 'add_meal_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final token = auth.token;
      context.read<OrderProvider>().fetchAllOrders(token);
      context.read<OrderProvider>().fetchAnalytics(token);
      context.read<MealProvider>().fetchMeals();
      context.read<AuthProvider>().fetchAllUsers(token);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor: isDark ? AppColors.darkText : AppColors.lightText,
        elevation: 0,
        leading: GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Analytics'),
            Tab(text: 'Orders'),
            Tab(text: 'Meals'),
            Tab(text: 'Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AnalyticsTab(isDark: isDark),
          _AllOrdersTab(isDark: isDark, token: auth.token),
          _MealsTab(isDark: isDark, token: auth.token),
          _UsersTab(isDark: isDark, token: auth.token),
        ],
      ),
    );
  }
}

// ─── Analytics Tab ──────────────────────────────────────────────────────────
class _AnalyticsTab extends StatelessWidget {
  final bool isDark;
  const _AnalyticsTab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<OrderProvider>().analytics;
    if (analytics.isEmpty) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    final stats = [
      {'label': 'Total Orders', 'value': '${analytics['totalOrders'] ?? 0}', 'icon': Icons.receipt_long, 'color': AppColors.primary},
      {'label': 'Paid Orders', 'value': '${analytics['paidOrders'] ?? 0}', 'icon': Icons.payment, 'color': AppColors.success},
      {'label': 'Delivered', 'value': '${analytics['deliveredOrders'] ?? 0}', 'icon': Icons.local_shipping, 'color': AppColors.accent},
      {'label': 'Revenue', 'value': '\$${(analytics['totalRevenue'] ?? 0).toStringAsFixed(2)}', 'icon': Icons.attach_money, 'color': const Color(0xFF7B1FA2)},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3),
      itemCount: stats.length,
      itemBuilder: (ctx, i) {
        final stat = stats[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: (stat['color'] as Color).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stat['value'] as String, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: stat['color'] as Color)),
                  Text(stat['label'] as String, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── All Orders Tab ──────────────────────────────────────────────────────────
class _AllOrdersTab extends StatelessWidget {
  final bool isDark;
  final String token;
  const _AllOrdersTab({required this.isDark, required this.token});

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();
    if (orderProv.loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    final orders = orderProv.allOrders;
    if (orders.isEmpty) return Center(child: Text('No orders yet', style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (ctx, i) {
        final order = orders[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID + Status
              Row(
                children: [
                  Expanded(child: Text('Order #${order.id.substring(order.id.length - 6).toUpperCase()}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.lightText))),
                  _StatusBadge(order: order),
                ],
              ),
              const SizedBox(height: 10),
              // Customer Info Section
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : const Color(0xFFFFF8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    if (order.userName.isNotEmpty)
                      _InfoRow(icon: Icons.person_outline, label: order.userName, isDark: isDark),
                    if (order.userEmail.isNotEmpty)
                      _InfoRow(icon: Icons.email_outlined, label: order.userEmail, isDark: isDark),
                    if (order.phoneNumber.isNotEmpty)
                      _InfoRow(icon: Icons.phone_outlined, label: order.phoneNumber, isDark: isDark),
                    if (order.location.isNotEmpty)
                      _InfoRow(icon: Icons.location_on_outlined, label: order.location, isDark: isDark),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Order items
              Text(order.orderItems.map((i) => '${i.name} x${i.qty}').join(', '), style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${order.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15)),
                  if (!order.isDelivered)
                    ElevatedButton(
                      onPressed: () async {
                        final ok = await context.read<OrderProvider>().markAsDelivered(order.id, token);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Marked as delivered' : 'Failed'), backgroundColor: ok ? AppColors.success : AppColors.error));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), elevation: 0),
                      child: const Text('Mark Delivered', style: TextStyle(fontSize: 11)),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderModel order;
  const _StatusBadge({required this.order});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (order.isDelivered) color = AppColors.success;
    else if (order.isPaid) color = AppColors.warning;
    else color = AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(order.status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _InfoRow({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkText : AppColors.lightText),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Meals Management Tab ────────────────────────────────────────────────────
class _MealsTab extends StatelessWidget {
  final bool isDark;
  final String token;
  const _MealsTab({required this.isDark, required this.token});

  @override
  Widget build(BuildContext context) {
    final mealProv = context.watch<MealProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (_, a, __) => const AddMealScreen(),
              transitionsBuilder: (ctx, anim, secAnim, child) => SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: child,
              ),
            )).then((_) => mealProv.fetchMeals()),
            icon: const Icon(Icons.add),
            label: const Text('Add New Meal'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
          ),
        ),
        Expanded(
          child: mealProv.loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : mealProv.meals.isEmpty
                  ? Center(child: Text('No meals added yet', style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: mealProv.meals.length,
                      itemBuilder: (ctx, i) {
                        final meal = mealProv.meals[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: isDark ? AppColors.darkCard : AppColors.lightCard, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: meal.fullImageUrl,
                                  width: 50, height: 50, fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(color: AppColors.primary.withOpacity(0.1), width: 50, height: 50, child: const Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 1.5)))),
                                  errorWidget: (_, __, ___) => Container(width: 50, height: 50, color: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.restaurant, color: AppColors.primary, size: 20)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(meal.name, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.lightText)),
                                    Text('\$${meal.price.toStringAsFixed(2)} • ${meal.category}', style: const TextStyle(color: AppColors.lightSubtext, fontSize: 12)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                onPressed: () async {
                                  final ok = await mealProv.deleteMeal(meal.id, token);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Meal deleted' : 'Failed to delete'), backgroundColor: ok ? AppColors.success : AppColors.error));
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

// ─── Users Management Tab ────────────────────────────────────────────────────
class _UsersTab extends StatefulWidget {
  final bool isDark;
  final String token;
  const _UsersTab({required this.isDark, required this.token});

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final users = authProv.allUsers;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddUserDialog(context),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Add User / Restaurant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
        Expanded(
          child: authProv.loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : users.isEmpty
                  ? Center(
                      child: Text(
                        'No users found',
                        style: TextStyle(
                          color: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: users.length,
                      itemBuilder: (ctx, i) {
                        final user = users[i];
                        final isCurrentUser = user.id == authProv.user?.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
                            ],
                            border: isCurrentUser
                                ? Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5)
                                : null,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: user.isAdmin
                                    ? AppColors.primary.withOpacity(0.15)
                                    : user.isRestaurant
                                        ? AppColors.success.withOpacity(0.15)
                                        : Colors.grey.withOpacity(0.15),
                                child: Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                  style: TextStyle(
                                    color: user.isAdmin
                                        ? AppColors.primary
                                        : user.isRestaurant
                                            ? AppColors.success
                                            : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          user.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: widget.isDark ? AppColors.darkText : AppColors.lightText,
                                          ),
                                        ),
                                        if (isCurrentUser) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'You',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      user.email,
                                      style: TextStyle(
                                        color: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    _RoleBadge(user: user),
                                  ],
                                ),
                              ),
                              if (!isCurrentUser) ...[
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                                  onPressed: () => _showEditUserDialog(context, user),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                  onPressed: () => _confirmDeleteUser(context, user),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool isRestaurant = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Add User / Restaurant', style: TextStyle(fontWeight: FontWeight.bold, color: widget.isDark ? AppColors.darkText : AppColors.lightText)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: widget.isDark ? AppColors.darkText : AppColors.lightText),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      style: TextStyle(color: widget.isDark ? AppColors.darkText : AppColors.lightText),
                      decoration: InputDecoration(
                        labelText: 'Email (ends with @gmail.com for Admin)',
                        labelStyle: TextStyle(color: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      style: TextStyle(color: widget.isDark ? AppColors.darkText : AppColors.lightText),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text('Is Restaurant Account?', style: TextStyle(color: widget.isDark ? AppColors.darkText : AppColors.lightText)),
                      subtitle: Text('This account can see and deliver orders', style: TextStyle(color: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext, fontSize: 11)),
                      value: isRestaurant,
                      onChanged: (val) {
                        setState(() => isRestaurant = val);
                      },
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty ||
                        emailController.text.trim().isEmpty ||
                        passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    final authProv = context.read<AuthProvider>();
                    final ok = await authProv.createUserByAdmin(
                      widget.token,
                      nameController.text.trim(),
                      emailController.text.trim(),
                      passwordController.text,
                      isRestaurant,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? 'Account created successfully'
                              : authProv.error ?? 'Failed to create account'),
                          backgroundColor: ok ? AppColors.success : AppColors.error,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditUserDialog(BuildContext context, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController();
    bool isRestaurant = user.isRestaurant;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Edit User / Restaurant', style: TextStyle(fontWeight: FontWeight.bold, color: widget.isDark ? AppColors.darkText : AppColors.lightText)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: widget.isDark ? AppColors.darkText : AppColors.lightText),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      style: TextStyle(color: widget.isDark ? AppColors.darkText : AppColors.lightText),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      style: TextStyle(color: widget.isDark ? AppColors.darkText : AppColors.lightText),
                      decoration: InputDecoration(
                        labelText: 'Password (leave blank to keep current)',
                        labelStyle: TextStyle(color: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text('Is Restaurant Account?', style: TextStyle(color: widget.isDark ? AppColors.darkText : AppColors.lightText)),
                      subtitle: Text('This account can see and deliver orders', style: TextStyle(color: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext, fontSize: 11)),
                      value: isRestaurant,
                      onChanged: (val) {
                        setState(() => isRestaurant = val);
                      },
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty ||
                        emailController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name and Email cannot be empty')),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    final authProv = context.read<AuthProvider>();
                    final ok = await authProv.updateUserByAdmin(
                      widget.token,
                      user.id,
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      password: passwordController.text,
                      isRestaurant: isRestaurant,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? 'Account updated successfully'
                              : authProv.error ?? 'Failed to update account'),
                          backgroundColor: ok ? AppColors.success : AppColors.error,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteUser(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: widget.isDark ? AppColors.darkCard : AppColors.lightCard,
          title: Text('Delete Account', style: TextStyle(color: widget.isDark ? AppColors.darkText : AppColors.lightText)),
          content: Text('Are you sure you want to delete the account for "${user.name}"? This action cannot be undone.', style: TextStyle(color: widget.isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final authProv = context.read<AuthProvider>();
                final ok = await authProv.deleteUserByAdmin(widget.token, user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok
                          ? 'Account deleted successfully'
                          : authProv.error ?? 'Failed to delete account'),
                      backgroundColor: ok ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserModel user;
  const _RoleBadge({required this.user});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String badgeText;

    if (user.isAdmin) {
      badgeColor = AppColors.primary;
      badgeText = 'Admin';
    } else if (user.isRestaurant) {
      badgeColor = AppColors.success;
      badgeText = 'Restaurant';
    } else {
      badgeColor = Colors.grey;
      badgeText = 'User';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
