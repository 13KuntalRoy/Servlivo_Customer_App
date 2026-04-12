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

  final _pages = const [
    _OnboardingPage(
      title: 'From chores to\ncheers — we\nhandle it all',
      subtitle: 'Book verified women professionals for cleaning, care, chef services, and celebrations in just a few taps.',
      badge: 'TRUSTED BY HOMES. LOVED FOR EVENTS.',
      features: ['OTP start', 'Live tracking', 'Free replacement'],
    ),
    _OnboardingPage(
      title: 'Verified Pros\nat Your Door',
      subtitle: 'All our professionals are background-verified and trained. Your safety and satisfaction guaranteed.',
      badge: 'TRUSTED BY HOMES. LOVED FOR EVENTS.',
      features: ['Background verified', 'Insured service', '4.9 avg rating'],
    ),
    _OnboardingPage(
      title: 'Book in\nUnder 2 Minutes',
      subtitle: 'Select a service, pick a slot, and we\'ll match you with the best expert nearby.',
      badge: 'TRUSTED BY HOMES. LOVED FOR EVENTS.',
      features: ['6,000+ families served', '<2 min to book', 'Instant confirmation'],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Skip ›', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _pages[i],
              ),
            ),

            // Dots + button
            Padding(
              padding: const EdgeInsets.all(24),
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
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.primary
                              : AppColors.divider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CTA button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        context.go(AppRoutes.login);
                      }
                    },
                    child: Text(
                      _currentPage < _pages.length - 1
                          ? 'Next →'
                          : 'Get Started →',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(color: AppColors.textSecondary),
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

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final List<String> features;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Illustration placeholder
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.divider.withValues(alpha:0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Icon(Icons.home_repair_service, size: 80, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Feature pills
          Wrap(
            spacing: 8,
            children: features
                .map((f) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text(f, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
