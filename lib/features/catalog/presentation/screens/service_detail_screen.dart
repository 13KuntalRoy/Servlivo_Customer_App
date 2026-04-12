import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/catalog_cubit.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String serviceId;

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        return Scaffold(
          body: switch (state) {
            CatalogLoading() => const Center(child: CircularProgressIndicator()),
            CatalogError(:final message) => Scaffold(
                appBar: AppBar(),
                body: Center(child: Text(message)),
              ),
            ServiceDetailLoaded(:final service) => CustomScrollView(
                slivers: [
                  // Hero image
                  SliverAppBar(
                    expandedHeight: 240,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: service.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: service.imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.background,
                                child: const Icon(Icons.home_repair_service,
                                    size: 80, color: AppColors.textHint),
                              ),
                            )
                          : Container(
                              color: AppColors.background,
                              child: const Icon(Icons.home_repair_service,
                                  size: 80, color: AppColors.textHint),
                            ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Text(service.name,
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(service.durationDisplay,
                                style: const TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(width: 16),
                            const Icon(Icons.people_outline, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text('${service.vendorCount} vendors',
                                style: const TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(service.description,
                            style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text('Price', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('₹${service.basePrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            )),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            _ => const Center(child: CircularProgressIndicator()),
          },
          bottomNavigationBar: state is ServiceDetailLoaded
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: () => context.push(
                        AppRoutes.bookingCreate,
                        extra: {'service_id': state.service.id, 'service_price': state.service.basePrice},
                      ),
                      child: Text('Book Now — ₹${state.service.basePrice.toStringAsFixed(0)}'),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
