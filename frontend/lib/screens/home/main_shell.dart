// ignore_for_file: unnecessary_underscores, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/meal_provider.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';
import 'home_tab.dart';
import '../orders/my_orders_screen.dart';
import '../explore/explore_screen.dart';
import '../favorites/favorites_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _searchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _searchAnim;
  late Animation<double> _searchFade;

  final List<Widget> _tabs = const [
    HomeTab(),
    MyOrdersScreen(),
    FavoritesScreen(),
    ExploreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _searchAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _searchFade = CurvedAnimation(parent: _searchAnim, curve: Curves.easeInOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealProvider>().fetchMeals();
    });
  }

  @override
  void dispose() {
    _searchAnim.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searchVisible = !_searchVisible);
    if (_searchVisible) {
      _searchAnim.forward();
    } else {
      _searchAnim.reverse();
      _searchController.clear();
      context.read<MealProvider>().fetchMeals();
    }
  }

  void _onSearch(String value) {
    context.read<MealProvider>().fetchMeals(search: value);
  }

  void _navigateToCart() {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, a, __) => const CartScreen(),
      transitionsBuilder: (ctx, anim, secAnim, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
    ));
  }

  void _navigateToProfile() {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, a, __) => const ProfileScreen(),
      transitionsBuilder: (ctx, anim, secAnim, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          // ─── Top Header ───────────────────────────────────────────
          Container(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Normal header row
                  AnimatedOpacity(
                    opacity: _searchVisible ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          // App logo + title
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Food Hub',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          ),
                          const Spacer(),
                          // Search icon
                          IconButton(
                            icon: const Icon(Icons.search_rounded),
                            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                            onPressed: _toggleSearch,
                          ),
                          // Cart icon with badge
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.shopping_cart_outlined),
                                color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                                onPressed: _navigateToCart,
                              ),
                              if (cart.itemCount > 0)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                    child: Text(
                                      '${cart.itemCount}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          // Profile icon
                          GestureDetector(
                            onTap: _navigateToProfile,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primary.withOpacity(0.15),
                              child: Text(
                                auth.isLoggedIn ? (auth.user!.name.isNotEmpty ? auth.user!.name[0].toUpperCase() : 'U') : 'G',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Search overlay
                  FadeTransition(
                    opacity: _searchFade,
                    child: _searchVisible
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus: true,
                                    onChanged: _onSearch,
                                    decoration: InputDecoration(
                                      hintText: 'Search meals...',
                                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                      ),
                                      filled: true,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: _toggleSearch,
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // ─── Tabs ─────────────────────────────────────────────────
          Container(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: _TopTabBar(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
          ),

          // ─── Body ─────────────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _tabs[_currentIndex],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TopTabBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = [
      (Icons.home_rounded, 'Home'),
      (Icons.receipt_long_rounded, 'My Orders'),
      (Icons.favorite_rounded, 'Favorites'),
      (Icons.explore_rounded, 'Explore'),
    ];

    return Row(
      children: List.generate(tabs.length, (i) {
        final isSelected = currentIndex == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    tabs[i].$1,
                    size: 22,
                    color: isSelected ? AppColors.primary : (isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tabs[i].$2,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : (isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
