import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/subscription_cubit.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Subscriptions')),
      body: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SubscriptionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<SubscriptionCubit>().load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is SubscriptionLoaded) {
            if (state.subscriptions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.repeat, size: 64, color: AppColors.divider),
                    const SizedBox(height: 16),
                    const Text('No active subscriptions',
                        style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go(AppRoutes.catalog),
                      child: const Text('Browse Services'),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.subscriptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final sub = state.subscriptions[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(sub.serviceName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                          _StatusChip(status: sub.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.repeat, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            sub.frequency[0].toUpperCase() + sub.frequency.substring(1),
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.calendar_today,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Next: ${DateFormat('dd MMM').format(sub.nextServiceDate)}',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('₹${sub.price.toStringAsFixed(0)} per service',
                          style: const TextStyle(
                              color: AppColors.primary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (sub.isActive)
                            OutlinedButton(
                              onPressed: () =>
                                  context.read<SubscriptionCubit>().pause(sub.id),
                              child: const Text('Pause'),
                            )
                          else if (sub.status == 'paused')
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<SubscriptionCubit>().resume(sub.id),
                              child: const Text('Resume'),
                            ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => _confirmCancel(context, sub.id),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _confirmCancel(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text('Are you sure you want to cancel this subscription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<SubscriptionCubit>().cancel(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      'active' => (AppColors.secondary, AppColors.secondary.withValues(alpha:0.1)),
      'paused' => (Colors.orange, Colors.orange.withValues(alpha:0.1)),
      _ => (Colors.red, Colors.red.withValues(alpha:0.1)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
