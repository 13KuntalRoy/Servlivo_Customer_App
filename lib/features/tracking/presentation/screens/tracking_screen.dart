import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/tracking_bloc.dart';

class TrackingScreen extends StatelessWidget {
  final String bookingId;
  final String? vendorName;
  final String? completionCode;
  final String? bookingStatus;

  const TrackingScreen({
    super.key,
    required this.bookingId,
    this.vendorName,
    this.completionCode,
    this.bookingStatus,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackingBloc, TrackingState>(
      builder: (context, state) {
        final location = state is TrackingConnected ? state.location : null;

        return Scaffold(
          body: Stack(
            children: [
              // Google Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: location != null
                      ? LatLng(location.latitude, location.longitude)
                      : const LatLng(20.5937, 78.9629), // India center — pans to vendor once connected
                  zoom: location != null ? 15 : 5,
                ),
                markers: location != null
                    ? {
                        Marker(
                          markerId: const MarkerId('vendor'),
                          position: LatLng(location.latitude, location.longitude),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueOrange,
                          ),
                          infoWindow: InfoWindow(title: vendorName ?? 'Your Expert'),
                        ),
                      }
                    : {},
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),

              // Status bar at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tracking Order',
                                  style: TextStyle(fontWeight: FontWeight.w700)),
                              Text(
                                switch (state) {
                                  TrackingConnecting() => 'Connecting...',
                                  TrackingConnected(location: null) =>
                                    'Waiting for vendor location...',
                                  TrackingConnected(location: _?) =>
                                    'Vendor is on the way',
                                  TrackingDisconnected() => 'Disconnected',
                                  TrackingError(:final message) => message,
                                  _ => '',
                                },
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.help_outline, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom sheet
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _TrackingBottomSheet(
                  bookingId: bookingId,
                  location: location,
                  vendorName: vendorName,
                  completionCode: completionCode,
                  bookingStatus: bookingStatus,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TrackingBottomSheet extends StatelessWidget {
  final String bookingId;
  final dynamic location;
  final String? vendorName;
  final String? completionCode;
  final String? bookingStatus;

  const _TrackingBottomSheet({
    required this.bookingId,
    required this.location,
    this.vendorName,
    this.completionCode,
    this.bookingStatus,
  });

  Future<void> _openChat(BuildContext context) async {
    try {
      final dio = sl<Dio>();
      final response = await dio.post(Endpoints.chatRooms, data: {
        'booking_id': bookingId,
      });
      final roomId = response.data['id'] as String;
      if (context.mounted) {
        context.push(
          AppRoutes.chatRoomPath(roomId),
          extra: {'vendor_name': vendorName},
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open chat. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ETA
          if (location != null) ...[
            Text(
              'Arriving in ${location.etaDisplay}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${(location.speed).toStringAsFixed(1)} km/h',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
          ],

          // Progress steps — active step driven by booking status
          _ProgressSteps(bookingStatus: bookingStatus),

          const SizedBox(height: 16),

          // Vendor card
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.divider,
                child: Text(
                  (vendorName?.isNotEmpty == true) ? vendorName![0].toUpperCase() : 'V',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  vendorName ?? 'Service Expert',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // OTP
          if (completionCode != null && completionCode!.isNotEmpty) ...[
            const Center(
              child: Text('SHARE OTP TO START SERVICE',
                  style: TextStyle(fontSize: 11, letterSpacing: 0.5, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                completionCode!.split('').join('  '),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Do not share this with anyone else',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Chat and call buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openChat(context),
                  icon: const Icon(Icons.chat_outlined, size: 16),
                  label: const Text('Chat'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Calling is not available in this version'),
                    ),
                  ),
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Call Expert'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressSteps extends StatelessWidget {
  final String? bookingStatus;

  const _ProgressSteps({this.bookingStatus});

  /// Maps booking status string to 0-based progress step index.
  /// Steps: 0=Confirmed, 1=En Route, 2=Arrived, 3=Done
  int get _activeIndex {
    switch (bookingStatus) {
      case 'confirmed':
        return 0;
      case 'vendorAccepted':
        return 1;
      case 'serviceStarted':
        return 2;
      case 'serviceCompleted':
        return 3;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    const steps = ['Confirmed', 'En Route', 'Arrived', 'Done'];
    final activeIndex = _activeIndex;

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final filled = i ~/ 2 < activeIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: filled ? AppColors.secondary : AppColors.divider,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isActive = stepIndex == activeIndex;
        final isDone = stepIndex < activeIndex;

        return Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? AppColors.secondary
                    : isActive
                        ? AppColors.primary
                        : AppColors.surface,
                border: Border.all(
                  color: isDone || isActive ? AppColors.secondary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : isActive
                      ? const Icon(Icons.two_wheeler, color: Colors.white, size: 14)
                      : Icon(
                          stepIndex == 2 ? Icons.location_on_outlined : Icons.check,
                          color: AppColors.textHint,
                          size: 14,
                        ),
            ),
            const SizedBox(height: 4),
            Text(steps[stepIndex],
                style: TextStyle(
                  fontSize: 10,
                  color: isDone || isActive ? AppColors.textPrimary : AppColors.textHint,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                )),
          ],
        );
      }),
    );
  }
}
