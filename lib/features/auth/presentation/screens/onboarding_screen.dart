import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _PageData(
      image: 'assets/images/onboarding1.png',
      bgColor: Color(0xFFFFEDE3),
      badge: 'TRUSTED BY HOMES. LOVED FOR EVENTS',
      titleStart: 'From ',
      titleHighlight: 'chores',
      titleEnd: ' to cheers —\nwe handle it all',
      subtitle:
          'Book verified women professionals for cleaning, care, chef services, and celebrations in just a few taps.',
      featureBar: '⚡  OTP start  •  Live tracking  •  Free replacement',
      stats: [
        _Stat(icon: Icons.star_rounded, value: '4.9', label: 'avg rating'),
        _Stat(icon: Icons.people_alt_rounded, value: '6,000+', label: 'families served'),
        _Stat(icon: Icons.access_time_rounded, value: '<2 min', label: 'to book'),
      ],
    ),
    _PageData(
      image: 'assets/images/onboarding2.png',
      bgColor: Color(0xFFE8F8F4),
      badge: 'EXPERT CHEFS AT YOUR DOOR',
      titleStart: 'Home-cooked ',
      titleHighlight: 'meals',
      titleEnd: ',\nprofessional taste',
      subtitle:
          'From daily meals to special occasions — our certified chefs bring restaurant-quality food right to your home.',
      featureBar: '👨‍🍳  Certified chefs  •  Fresh ingredients  •  Custom menu',
      stats: [
        _Stat(icon: Icons.verified_rounded, value: '100%', label: 'certified'),
        _Stat(icon: Icons.restaurant_rounded, value: '50+', label: 'cuisines'),
        _Stat(icon: Icons.thumb_up_rounded, value: '98%', label: 'satisfaction'),
      ],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/images/logo.png', width: 28, height: 28),
                      const SizedBox(width: 6),
                      const Text(
                        'Servlivo',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Pages ─────────────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _OnboardingPageWidget(data: _pages[i]),
              ),
            ),

            // ── Bottom controls ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 20 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.primary
                              : AppColors.divider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Next  →'
                            : 'Get Started  →',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sign In
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page widget ──────────────────────────────────────────────────────────────

class _OnboardingPageWidget extends StatelessWidget {
  final _PageData data;
  const _OnboardingPageWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Illustration card
          Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              color: data.bgColor,
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              data.image,
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            ),
          ),
          const SizedBox(height: 20),

          // Badge
          Text(
            data.badge,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),

          // Title with highlight
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.25,
              ),
              children: [
                TextSpan(text: data.titleStart),
                TextSpan(
                  text: data.titleHighlight,
                  style: const TextStyle(color: AppColors.primary),
                ),
                TextSpan(text: data.titleEnd),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle
          Text(
            data.subtitle,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),

          // Feature bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDE7),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Text(
              data.featureBar,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7A5C00),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stats row
          Row(
            children: data.stats
                .map(
                  (s) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(s.icon, size: 22, color: AppColors.primary),
                          const SizedBox(height: 6),
                          Text(
                            s.value,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.label,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Data models ──────────────────────────────────────────────────────────────

class _PageData {
  final String image;
  final Color bgColor;
  final String badge;
  final String titleStart;
  final String titleHighlight;
  final String titleEnd;
  final String subtitle;
  final String featureBar;
  final List<_Stat> stats;

  const _PageData({
    required this.image,
    required this.bgColor,
    required this.badge,
    required this.titleStart,
    required this.titleHighlight,
    required this.titleEnd,
    required this.subtitle,
    required this.featureBar,
    required this.stats,
  });
}

class _Stat {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({required this.icon, required this.value, required this.label});
}
