import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/home_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 64, color: AppColors.divider),
                  const SizedBox(height: 16),
                  Text(state.message,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<HomeBloc>().add(const HomeDataRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is HomeLoaded) {
            final data = state.data;
            return CustomScrollView(
              slivers: [
                // App bar with greeting
                SliverAppBar(
                  floating: true,
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.greeting,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.primary),
                          const SizedBox(width: 2),
                          Text(
                            data.currentAddress ?? 'Select location',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: AppColors.textPrimary),
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      ),
                    ),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Prime banner
                        if (!data.hasPrimeMembership)
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.prime),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1A1A2E), AppColors.primary],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.workspace_premium,
                                      color: Colors.amber, size: 28),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Unlock Servlivo Prime',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700)),
                                        Text('Save up to 30% on every booking',
                                            style: TextStyle(
                                                color: Colors.white70, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('Try Now',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Ongoing booking
                        if (data.ongoingBooking != null) ...[
                          GestureDetector(
                            onTap: () => context.push(
                                AppRoutes.trackingDetailPath(
                                    data.ongoingBooking!.bookingId),
                                extra: {
                                  'vendor_name': data.ongoingBooking!.vendorName,
                                  'booking_status': data.ongoingBooking!.status,
                                }),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.secondary.withValues(alpha:0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.two_wheeler,
                                      color: AppColors.secondary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(data.ongoingBooking!.serviceName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                        Text(
                                            '${data.ongoingBooking!.vendorName} • ${_statusLabel(data.ongoingBooking!.status)}',
                                            style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  const Text('Track',
                                      style: TextStyle(
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  const Icon(Icons.chevron_right,
                                      color: AppColors.secondary, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],

                        // Categories
                        const Text('Our Services',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // Categories grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final cat = data.categories[i];
                        return GestureDetector(
                          onTap: () => context.push(
                            AppRoutes.catalog,
                            extra: {'category_id': cat.id},
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: cat.iconUrl.isNotEmpty
                                    ? Image.network(cat.iconUrl,
                                        width: 32, height: 32)
                                    : Icon(
                                        _iconForCategory(cat.name),
                                        color: AppColors.primary,
                                        size: 28,
                                      ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: data.categories.length,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Popular services header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Popular Services',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.catalog),
                          child: const Text('See All',
                              style: TextStyle(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                ),

                // Popular services horizontal scroll
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: data.popularServices.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final service = data.popularServices[i];
                        return GestureDetector(
                          onTap: () => context.push(
                              AppRoutes.serviceDetailPath(service.id)),
                          child: Container(
                            width: 160,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: service.imageUrl.isNotEmpty
                                      ? Image.network(
                                          service.imageUrl,
                                          height: 100,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 100,
                                          color: AppColors.primary
                                              .withValues(alpha:0.1),
                                          child: const Center(
                                            child: Icon(Icons.home_repair_service,
                                                color: AppColors.primary,
                                                size: 40),
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(service.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              size: 12, color: AppColors.star),
                                          const SizedBox(width: 2),
                                          Text(service.rating.toStringAsFixed(1),
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      AppColors.textSecondary)),
                                          const Spacer(),
                                          Text(
                                              '₹${service.price.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _statusLabel(String status) {
    return switch (status) {
      'vendorAccepted' => 'En Route',
      'serviceStarted' => 'In Progress',
      'confirmed' => 'Confirmed',
      _ => status,
    };
  }

  IconData _iconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('clean')) return Icons.cleaning_services;
    if (lower.contains('plumb')) return Icons.plumbing;
    if (lower.contains('electr')) return Icons.electrical_services;
    if (lower.contains('beauty') || lower.contains('spa')) return Icons.spa;
    if (lower.contains('paint')) return Icons.format_paint;
    if (lower.contains('pest')) return Icons.pest_control;
    if (lower.contains('carpenter')) return Icons.handyman;
    if (lower.contains('ac') || lower.contains('appliance')) return Icons.air;
    return Icons.home_repair_service;
  }
}
