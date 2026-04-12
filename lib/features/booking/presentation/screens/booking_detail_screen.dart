import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/booking_entity.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../../../reviews/presentation/cubit/review_cubit.dart';
import '../../../reviews/presentation/screens/post_review_screen.dart';

class BookingDetailScreen extends StatelessWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Booking Details')),
          body: switch (state) {
            BookingLoading() => const Center(child: CircularProgressIndicator()),
            BookingError(:final message) => Center(child: Text(message)),
            BookingDetailLoaded(:final booking) => _BookingDetailBody(booking: booking),
            _ => const Center(child: CircularProgressIndicator()),
          },
        );
      },
    );
  }
}

class _BookingDetailBody extends StatelessWidget {
  final BookingEntity booking;

  const _BookingDetailBody({required this.booking});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha:0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha:0.2)),
            ),
            child: Column(
              children: [
                Text(
                  booking.status.displayLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '#SRV-${booking.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(booking.scheduledAt),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // OTP section (if confirmed)
          if (booking.completionCode.isNotEmpty &&
              booking.status == BookingStatus.confirmed) ...[
            const Text('SHARE OTP TO START SERVICE',
                style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.5,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
                color: AppColors.surface,
              ),
              child: Column(
                children: [
                  Text(
                    booking.completionCode.split('').join('  '),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 8,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Do not share this with anyone else',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Price breakdown
          Text('Price Breakdown', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _PriceRow('Service', '₹${(booking.totalAmount - booking.taxAmount).toStringAsFixed(0)}'),
          _PriceRow('Tax', '₹${booking.taxAmount.toStringAsFixed(0)}'),
          const Divider(),
          _PriceRow('Total', '₹${booking.totalAmount.toStringAsFixed(0)}', bold: true),

          const SizedBox(height: 24),

          // Actions
          if (booking.status.canTrack)
            ElevatedButton.icon(
              onPressed: () => context.push(
                AppRoutes.trackingDetailPath(booking.id),
                extra: {
                  'vendor_name': booking.vendorName,
                  'completion_code': booking.completionCode,
                  'booking_status': booking.status.name,
                },
              ),
              icon: const Icon(Icons.location_on_outlined),
              label: const Text('Track Vendor'),
            ),
          const SizedBox(height: 12),

          // Chat with vendor — available once booking is confirmed
          if (booking.status != BookingStatus.created &&
              booking.status != BookingStatus.cancelled)
            OutlinedButton.icon(
              onPressed: () => _openChat(context, booking),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Chat with Vendor'),
            ),
          const SizedBox(height: 12),

          if (booking.status.canCancel)
            OutlinedButton(
              onPressed: () => _showCancelDialog(context),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Cancel Booking'),
            ),
          const SizedBox(height: 12),

          // Leave a review once the service is completed
          if (booking.status.isCompleted)
            ElevatedButton.icon(
              onPressed: () => _openReview(context, booking),
              icon: const Icon(Icons.star_outline),
              label: const Text('Leave a Review'),
            ),
        ],
      ),
    );
  }

  Future<void> _openChat(BuildContext context, BookingEntity booking) async {
    try {
      final dio = sl<Dio>();
      final response = await dio.post(Endpoints.chatRooms, data: {
        'booking_id': booking.id,
        'customer_id': booking.customerId,
        'vendor_id': booking.vendorId,
      });
      final roomId = response.data['id'] as String;
      if (context.mounted) {
        context.push(
          AppRoutes.chatRoomPath(roomId),
          extra: {'vendor_name': booking.vendorName},
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open chat. Try again.')),
        );
      }
    }
  }

  Future<void> _openReview(BuildContext context, BookingEntity booking) async {
    await Navigator.of(context).push(
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
    );
  }

  void _showCancelDialog(BuildContext context) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
            labelText: 'Reason for cancellation',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep')),
          TextButton(
            onPressed: () {
              final reason = reasonCtrl.text.trim();
              Navigator.pop(context);
              context.read<BookingBloc>().add(
                    BookingCancelRequested(
                      bookingId: booking.id,
                      reason: reason,
                    ),
                  );
            },
            child: const Text('Cancel Booking', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    ).then((_) => reasonCtrl.dispose());
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _PriceRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
                  color: bold ? AppColors.textPrimary : AppColors.textSecondary,
                )),
          ),
          Text(value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                fontSize: bold ? 16 : 14,
              )),
        ],
      ),
    );
  }
}
