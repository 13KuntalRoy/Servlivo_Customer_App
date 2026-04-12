import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/prime_cubit.dart';

class PrimeScreen extends StatefulWidget {
  const PrimeScreen({super.key});

  @override
  State<PrimeScreen> createState() => _PrimeScreenState();
}

class _PrimeScreenState extends State<PrimeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PrimeCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<PrimeCubit, PrimeState>(
        builder: (context, state) {
          if (state is PrimeLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PrimeError) {
            return Center(child: Text(state.message));
          }
          if (state is PrimeLoaded) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1A1A2E), AppColors.primary],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.workspace_premium,
                                      color: Colors.amber, size: 28),
                                  SizedBox(width: 8),
                                  Text('Servlivo Prime',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (state.isMember)
                                Text(
                                  '${state.membership!.daysRemaining} days remaining',
                                  style: const TextStyle(
                                      color: Colors.amber, fontSize: 14),
                                )
                              else
                                const Text(
                                  'Unlock exclusive benefits & save more',
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                if (state.isMember) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, color: Colors.amber),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Active Member',
                                    style: TextStyle(fontWeight: FontWeight.w700)),
                                Text(
                                  'Plan: ${state.membership!.planName}',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // Plans
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      state.isMember ? 'Upgrade Your Plan' : 'Choose Your Plan',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final plan = state.plans[i];
                      final isPopular = i == 1;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isPopular
                                    ? const Color(0xFF1A1A2E)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isPopular ? Colors.transparent : AppColors.border,
                                ),
                                boxShadow: isPopular
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha:0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    plan.name,
                                    style: TextStyle(
                                      color: isPopular ? Colors.white : AppColors.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${plan.price.toStringAsFixed(0)} / ${plan.durationDays} days',
                                    style: TextStyle(
                                      color: isPopular ? Colors.amber : AppColors.primary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...plan.benefits.map((benefit) => Padding(
                                        padding:
                                            const EdgeInsets.symmetric(vertical: 3),
                                        child: Row(
                                          children: [
                                            Icon(Icons.check_circle,
                                                size: 16,
                                                color: isPopular
                                                    ? Colors.amber
                                                    : AppColors.secondary),
                                            const SizedBox(width: 8),
                                            Text(
                                              benefit,
                                              style: TextStyle(
                                                color: isPopular
                                                    ? Colors.white70
                                                    : AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: state.isMember
                                          ? null
                                          : () => context
                                              .read<PrimeCubit>()
                                              .subscribe(plan.id),
                                      style: isPopular
                                          ? ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                            )
                                          : null,
                                      child: Text(
                                          state.isMember ? 'Current Plan' : 'Get Started'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isPopular)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('POPULAR',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black)),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    childCount: state.plans.length,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
