// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';
import '../admin/dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        foregroundColor: isDark ? AppColors.darkText : AppColors.lightText,
        elevation: 0,
        leading: GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar & Name
          Center(
            child: Column(
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
                  ),
                  child: Center(
                    child: Text(
                      auth.isLoggedIn ? (auth.user!.name.isNotEmpty ? auth.user!.name[0].toUpperCase() : 'U') : 'G',
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  auth.isLoggedIn ? auth.user!.name : 'Guest',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.lightText),
                ),
                const SizedBox(height: 4),
                if (auth.isLoggedIn)
                  Text(auth.user!.email, style: const TextStyle(color: AppColors.lightSubtext, fontSize: 14)),
                if (auth.isLoggedIn && auth.isAdmin)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Admin', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Settings Card
          _SettingsCard(isDark: isDark, children: [
            _SettingsTile(
              icon: themeProv.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              title: themeProv.isDark ? 'Light Mode' : 'Dark Mode',
              subtitle: 'Switch app theme',
              isDark: isDark,
              trailing: Switch(
                value: themeProv.isDark,
                onChanged: (_) => themeProv.toggleTheme(),
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primaryLight,
              ),
            ),
          ]),

          const SizedBox(height: 16),

          if (auth.isLoggedIn && auth.isAdmin) ...[
            _SettingsCard(isDark: isDark, children: [
              _SettingsTile(
                icon: Icons.dashboard_rounded,
                title: 'Admin Dashboard',
                subtitle: 'Manage meals & orders',
                isDark: isDark,
                onTap: () => Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (ctx, anim, secAnim) => const DashboardScreen(),
                  transitionsBuilder: (ctx, anim, secAnim, child) => SlideTransition(
                    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                    child: child,
                  ),
                )),
              ),
            ]),
            const SizedBox(height: 16),
          ],

          _SettingsCard(isDark: isDark, children: [
            if (auth.isLoggedIn)
              _SettingsTile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                isDark: isDark,
                iconColor: AppColors.error,
                onTap: () => showDialog(
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
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Logout', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                ),
              )
            else
              _SettingsTile(
                icon: Icons.login_rounded,
                title: 'Login',
                subtitle: 'Sign in to your account',
                isDark: isDark,
                iconColor: AppColors.primary,
                onTap: () => Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (ctx, anim, secAnim) => const LoginScreen(),
                  transitionsBuilder: (ctx, anim, secAnim, child) => SlideTransition(
                    position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                    child: child,
                  ),
                )),
              ),
          ]),
          const SizedBox(height: 30),
          Center(child: Text('Somalia Food Hub v1.0.0', style: TextStyle(color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext, fontSize: 12))),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10)],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.isDark, this.trailing, this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: (iconColor ?? AppColors.primary).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? AppColors.darkText : AppColors.lightText)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext)),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: AppColors.lightSubtext) : null),
    );
  }
}
