// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:somalia_food_hub/constants/app_colors.dart';
import 'constants/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/order_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home/main_shell.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/restaurant/restaurant_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const SomaliaFoodHub());
}

class SomaliaFoodHub extends StatelessWidget {
  const SomaliaFoodHub({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProv, authProv, _) {
          return MaterialApp(
            title: 'Somalia Food Hub',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProv.themeMode,
            home: const _AppEntry(),
            builder: (context, child) {
              return Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: child,
              );
            },
            onGenerateRoute: (settings) {
              // Slide-from-right for all named routes
              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (ctx, anim, secAnim) => const SizedBox.shrink(),
                transitionsBuilder: (ctx, anim, secAnim, child) => SlideTransition(
                  position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                      .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                  child: child,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _AppEntry extends StatelessWidget {
  const _AppEntry();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // While SharedPreferences loads the session, show a beautiful premium splash screen
    if (!auth.initialized) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF1E0A00), const Color(0xFF0F0702)]
                  : [const Color(0xFFFFF3E0), const Color(0xFFFFFDF9)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Branded pulsing logo container
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 50),
                ),
                const SizedBox(height: 24),
                Text(
                  'Food Hub',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Somalia\'s Premium Food Hub',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Once initialized, route to appropriate dashboard/shell based on user role
    if (auth.isLoggedIn) {
      if (auth.isRestaurant) {
        return const RestaurantDashboardScreen();
      }
      return const MainShell();
    }
    return const WelcomeScreen();
  }
}
