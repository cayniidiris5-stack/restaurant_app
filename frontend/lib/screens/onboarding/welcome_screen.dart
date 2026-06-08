// ignore_for_file: unnecessary_underscores, deprecated_member_use

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../auth/login_screen.dart';
import '../home/main_shell.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Somali Traditional Dishes',
      'subtitle': 'Experience authentic Somali Bariis, roasted Goat, beef Suqaar, and spiced Shaah brewed to perfection.',
      'icon': '🍽️',
    },
    {
      'title': 'Delivered Fresh & Fast',
      'subtitle': 'Your favorite gourmet meals prepared by master chefs and delivered hot directly to your doorstep.',
      'icon': '🚀',
    },
    {
      'title': 'Premium Dining Experience',
      'subtitle': 'Big menu selections, secure order tracking, and seamless payments all in one beautiful application.',
      'icon': '✨',
    },
  ];

  void _navigateToLogin() {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, a, __) => const LoginScreen(),
      transitionsBuilder: (ctx, anim, secAnim, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
    ));
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, a, __) => const MainShell(),
      transitionsBuilder: (ctx, anim, secAnim, child) => FadeTransition(
        opacity: anim,
        child: child,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Brand Logo Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.restaurant_menu, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Food Hub',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                ],
              ),
              
              // Onboarding Slides (PageView)
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (value) => setState(() => _currentPage = value),
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    final slide = _onboardingData[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Giant Emoji/Illustration placeholder inside glassmorphic ring
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.08),
                                  blurRadius: 24,
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                slide['icon']!,
                                style: const TextStyle(fontSize: 64),
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Title
                          Text(
                            slide['title']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkText : AppColors.lightText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Subtitle
                          Text(
                            slide['subtitle']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page Indicators (Dots)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? AppColors.primary : AppColors.primary.withOpacity(0.24),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Primary Sign In / Register button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _navigateToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Guest access text button
                    GestureDetector(
                      onTap: _navigateToHome,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Explore as Guest',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
