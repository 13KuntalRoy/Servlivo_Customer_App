import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/prime_cubit.dart';

class PrimeScreen extends StatefulWidget {
  const PrimeScreen({super.key});

  @override
  State<PrimeScreen> createState() => _PrimeScreenState();
}

class _PrimeScreenState extends State<PrimeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    context.read<PrimeCubit>().load();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _shimmerAnim =
        Tween<double>(begin: 0.6, end: 1.0).animate(_shimmerController);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<PrimeCubit, PrimeState>(
        builder: (context, state) {
          if (state is PrimeLoading) return _buildLoading();
          if (state is PrimeError) return _buildError(state.message);
          if (state is PrimeLoaded) return _buildLoaded(state);
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ─── Loading ─────────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Loading Prime plans...',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  // ─── Error ───────────────────────────────────────────────────────────────────

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: AppColors.error, size: 40),
            ),
            const SizedBox(height: 16),
            const Text('Something went wrong',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<PrimeCubit>().load(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Loaded ──────────────────────────────────────────────────────────────────

  Widget _buildLoaded(PrimeLoaded state) {
    return CustomScrollView(
      slivers: [
        _buildHeroAppBar(state),
        if (state.isMember) _buildActiveMemberCard(state),
        _buildWhyPrimeSection(),
        _buildSectionHeader(state),
        _buildPlansList(state),
        _buildReviewsSection(),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  // ─── Hero App Bar ─────────────────────────────────────────────────────────────

  SliverAppBar _buildHeroAppBar(PrimeLoaded state) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A2E),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E), Color(0xFF2A1A3E)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber.withValues(alpha: 0.06),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          AnimatedBuilder(
                            animation: _shimmerAnim,
                            builder: (_, __) => Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.amber
                                  .withValues(alpha: _shimmerAnim.value),
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Servlivo Prime',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (state.isMember)
                        _buildMembershipStatusBadge(state)
                      else ...[
                        const Text(
                          'Exclusive perks, priority service\nand so much more.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildHeroStats(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipStatusBadge(PrimeLoaded state) {
    final days = state.membership!.daysRemaining;
    final isExpiringSoon = days <= 7;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isExpiringSoon
            ? Colors.red.withValues(alpha: 0.2)
            : Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpiringSoon
              ? Colors.red.withValues(alpha: 0.4)
              : Colors.amber.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpiringSoon ? Icons.timer_outlined : Icons.verified_rounded,
            color: isExpiringSoon ? Colors.redAccent : Colors.amber,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isExpiringSoon
                ? '$days days left — renew soon!'
                : '$days days remaining',
            style: TextStyle(
              color: isExpiringSoon ? Colors.redAccent : Colors.amber,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStats() {
    return Row(
      children: [
        _heroStat('10k+', 'Members'),
        const SizedBox(width: 24),
        _heroStat('50+', 'Benefits'),
        const SizedBox(width: 24),
        _heroStat('4.9★', 'Rating'),
      ],
    );
  }

  Widget _heroStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  // ─── Active Member Card ───────────────────────────────────────────────────────

  Widget _buildActiveMemberCard(PrimeLoaded state) {
    final membership = state.membership!;
    final renewalDate = DateFormat('MMM d, yyyy').format(membership.endDate);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF2A1A3E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.workspace_premium_rounded,
                          color: Colors.amber, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Active Prime Member',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                          Text(membership.planName,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.5)),
                      ),
                      child: const Text('ACTIVE',
                          style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _memberInfoChip(
                        Icons.calendar_today_outlined, 'Renews $renewalDate'),
                    const Spacer(),
                    _memberInfoChip(Icons.timer_outlined,
                        '${membership.daysRemaining}d left'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _memberInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.white38),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  // ─── Why Prime Section ────────────────────────────────────────────────────────

  Widget _buildWhyPrimeSection() {
    const perks = [
      (Icons.flash_on_rounded, 'Priority\nBooking', AppColors.warning),
      (Icons.discount_rounded, 'Exclusive\nDiscounts', AppColors.secondary),
      (Icons.support_agent_rounded, '24/7\nSupport', AppColors.info),
      (Icons.stars_rounded, 'Premium\nServices', Colors.amber),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Why go Prime?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: perks.map((p) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _perkTile(p.$1, p.$2, p.$3),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _perkTile(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.9),
                height: 1.3),
          ),
        ],
      ),
    );
  }

  // ─── Section Header ───────────────────────────────────────────────────────────

  Widget _buildSectionHeader(PrimeLoaded state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
        child: Text(
          state.isMember ? 'Upgrade Your Plan' : 'Choose Your Plan',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary),
        ),
      ),
    );
  }

  // ─── Plans List ───────────────────────────────────────────────────────────────

  Widget _buildPlansList(PrimeLoaded state) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final plan = state.plans[i];
          final isPopular = i == 1;
          final isFree = plan.priceMonthly == 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _PlanCard(
              plan: plan,
              isPopular: isPopular,
              isFree: isFree,
              isMember: state.isMember,
              isCurrentPlan:
                  state.isMember && state.membership?.planId == plan.id,
              onSubscribe: () =>
                  context.read<PrimeCubit>().subscribe(plan.id),
            ),
          );
        },
        childCount: state.plans.length,
      ),
    );
  }

  // ─── Reviews Section ──────────────────────────────────────────────────────────

  Widget _buildReviewsSection() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 28, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What members say',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            SizedBox(height: 14),
            _ReviewCarousel(),
          ],
        ),
      ),
    );
  }
}

// ─── Review Carousel ──────────────────────────────────────────────────────────

class _ReviewCarousel extends StatefulWidget {
  const _ReviewCarousel();

  @override
  State<_ReviewCarousel> createState() => _ReviewCarouselState();
}

class _ReviewCarouselState extends State<_ReviewCarousel> {
  static const _reviews = [
    _Review(
      name: 'Priya S.',
      plan: 'Prime Gold Member',
      avatar: 'P',
      avatarColor: Color(0xFF7C3AED),
      text:
          '"Best investment for home services. Priority booking saves me every single week!"',
      stars: 5,
    ),
    _Review(
      name: 'Rahul M.',
      plan: 'Prime Silver Member',
      avatar: 'R',
      avatarColor: Color(0xFF0EA5E9),
      text:
          '"The exclusive discounts have already paid for the subscription twice over. Totally worth it."',
      stars: 5,
    ),
    _Review(
      name: 'Ananya K.',
      plan: 'Prime Gold Member',
      avatar: 'A',
      avatarColor: Color(0xFF10B981),
      text:
          '"24/7 support is a game changer. Got help at midnight before a family event. Lifesaver!"',
      stars: 5,
    ),
    _Review(
      name: 'Vikram T.',
      plan: 'Prime Silver Member',
      avatar: 'V',
      avatarColor: Color(0xFFF59E0B),
      text:
          '"Premium service quality is noticeably better. Everything feels handled with extra care."',
      stars: 4,
    ),
  ];

  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final next = (_currentPage + 1) % _reviews.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 178,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _reviews.length,
            itemBuilder: (context, i) {
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: i == _currentPage ? 1.0 : 0.5,
                child: _ReviewCard(review: _reviews[i]),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_reviews.length, (i) {
            final isActive = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _Review {
  final String name;
  final String plan;
  final String avatar;
  final Color avatarColor;
  final String text;
  final int stars;

  const _Review({
    required this.name,
    required this.plan,
    required this.avatar,
    required this.avatarColor,
    required this.text,
    required this.stars,
  });
}

class _ReviewCard extends StatelessWidget {
  final _Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: review.avatarColor.withValues(alpha: 0.2),
                child: Text(
                  review.avatar,
                  style: TextStyle(
                    color: review.avatarColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    Text(review.plan,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: i < review.stars ? Colors.amber : Colors.white24,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            review.text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Plan Card Widget ─────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final dynamic plan;
  final bool isPopular;
  final bool isFree;
  final bool isMember;
  final bool isCurrentPlan;
  final VoidCallback onSubscribe;

  const _PlanCard({
    required this.plan,
    required this.isPopular,
    required this.isFree,
    required this.isMember,
    required this.isCurrentPlan,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: isPopular
                ? const LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF2A1A3E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isPopular ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isPopular
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4), width: 1.5)
                : Border.all(color: AppColors.border),
            boxShadow: isPopular
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlanHeader(),
                const SizedBox(height: 12),
                _buildPriceRow(),
                const SizedBox(height: 14),
                Divider(color: isPopular ? Colors.white12 : AppColors.divider, height: 1),
                const SizedBox(height: 12),
                _buildBenefits(),
                const SizedBox(height: 16),
                _buildActionButton(context),
              ],
            ),
          ),
        ),
        if (isPopular) _buildPopularBadge(),
        if (isCurrentPlan) _buildCurrentBadge(),
      ],
    );
  }

  Widget _buildPlanHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isPopular
                ? Colors.amber.withValues(alpha: 0.15)
                : AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isFree
                ? Icons.auto_awesome_outlined
                : isPopular
                    ? Icons.workspace_premium_rounded
                    : Icons.diamond_outlined,
            color: isPopular ? Colors.amber : AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.name,
                style: TextStyle(
                  color: isPopular ? Colors.white : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (plan.tagline.isNotEmpty)
                Text(
                  plan.tagline,
                  style: TextStyle(
                    color:
                        isPopular ? Colors.white54 : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isFree)
          Text(
            '₹',
            style: TextStyle(
              color: isPopular ? Colors.amber : AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        Text(
          isFree ? 'FREE' : plan.priceMonthly.toStringAsFixed(0),
          style: TextStyle(
            color: isPopular ? Colors.amber : AppColors.primary,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        if (!isFree)
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 2),
            child: Text(
              '/ mo',
              style: TextStyle(
                color: isPopular ? Colors.white38 : AppColors.textHint,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBenefits() {
    return Column(
      children: plan.benefits
          .map<Widget>((benefit) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isPopular
                            ? Colors.amber.withValues(alpha: 0.15)
                            : AppColors.secondary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 11,
                        color: isPopular ? Colors.amber : AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        benefit,
                        style: TextStyle(
                          color: isPopular
                              ? Colors.white70
                              : AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (isCurrentPlan) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_rounded, color: AppColors.secondary, size: 16),
            SizedBox(width: 6),
            Text('Your Current Plan',
                style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isMember ? null : onSubscribe,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPopular ? AppColors.primary : null,
          foregroundColor: isPopular ? Colors.white : null,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: isPopular ? 4 : 1,
        ),
        child: Text(
          isFree
              ? 'Get Started Free'
              : isMember
                  ? 'Upgrade Plan'
                  : 'Subscribe Now',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildPopularBadge() {
    return Positioned(
      top: -1,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department_rounded,
                color: Colors.white, size: 12),
            SizedBox(width: 4),
            Text('MOST POPULAR',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBadge() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('YOUR PLAN',
            style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
      ),
    );
  }
}
