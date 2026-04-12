import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/booking_entity.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../../../reviews/presentation/cubit/review_cubit.dart';
import '../../../reviews/presentation/screens/post_review_screen.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _searchActive = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  final _tabs = const ['Upcoming', 'Ongoing', 'Completed'];
  final _filters = [null, 'confirmed,service_started', 'service_completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) {
          context.read<BookingBloc>().add(
                BookingsLoadRequested(statusFilter: _filters[_tabController.index]),
              );
        }
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchActive = !_searchActive;
      if (!_searchActive) {
        _searchQuery = '';
        _searchCtrl.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searchActive
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search by service or booking ID...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textHint),
                ),
                style: const TextStyle(fontSize: 15),
                onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              )
            : const Text('My Bookings'),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(_searchActive ? Icons.close : Icons.search),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BookingError) {
            return Center(child: Text(state.message));
          }
          if (state is BookingsLoaded) {
            final bookings = _searchQuery.isEmpty
                ? state.bookings
                : state.bookings.where((b) {
                    final name = (b.serviceName ?? '').toLowerCase();
                    final id = b.id.toLowerCase();
                    return name.contains(_searchQuery) || id.contains(_searchQuery);
                  }).toList();

            if (bookings.isEmpty) return const _EmptyBookings();
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _BookingCard(booking: bookings[i]),
            );
          }
          return const _EmptyBookings();
        },
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text('No bookings yet', style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.catalog),
            child: const Text('Explore Services'),
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingEntity booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = booking.status;
    final statusColor = switch (status) {
      BookingStatus.serviceCompleted => AppColors.statusCompleted,
      BookingStatus.cancelled => AppColors.statusCancelled,
      BookingStatus.confirmed || BookingStatus.serviceStarted => AppColors.statusOngoing,
      _ => AppColors.statusUpcoming,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.home_repair_service, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceName ?? 'Service',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(booking.vendorName ?? 'Vendor TBD',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.displayLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Vendor row
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.divider,
                child: Text(
                  booking.vendorName?.isNotEmpty == true
                      ? booking.vendorName![0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  booking.vendorName ?? 'Vendor TBD',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              Text(
                '₹${booking.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),

          const Divider(height: 20),

          // Date and booking ID
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd MMM yyyy, hh:mm a').format(booking.scheduledAt),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Text(
                '#SRV-${booking.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              if (status.isCompleted && booking.vendorRating == null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => sl<ReviewCubit>(),
                          child: PostReviewScreen(
                            bookingId: booking.id,
                            vendorId: booking.vendorId,
                            vendorName: booking.vendorName ?? 'Service Expert',
                          ),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.star_outline, size: 16),
                    label: const Text('Rate & Review'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              if (status.isCompleted && booking.vendorRating == null)
                const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => status == BookingStatus.cancelled
                      ? context.push(AppRoutes.serviceDetailPath(booking.serviceId))
                      : context.push(AppRoutes.bookingDetailPath(booking.id)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: Text(
                    status == BookingStatus.cancelled ? 'Book Again' : 'View Details',
                  ),
                ),
              ),
              if (status.isActive) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.push(
                      AppRoutes.trackingDetailPath(booking.id),
                      extra: {
                        'vendor_name': booking.vendorName,
                        'completion_code': booking.completionCode,
                        'booking_status': booking.status.name,
                      },
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    child: const Text('Track'),
                  ),
                ),
              ],
              if (status.isCompleted) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(
                      AppRoutes.serviceDetailPath(booking.serviceId),
                    ),
                    icon: const Icon(Icons.refresh, size: 14),
                    label: const Text('Re-book'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
