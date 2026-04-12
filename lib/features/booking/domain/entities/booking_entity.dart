import 'package:equatable/equatable.dart';

enum BookingStatus {
  created,
  vendorRequested,
  vendorAccepted,
  paymentPending,
  confirmed,
  serviceStarted,
  serviceCompleted,
  cancelled;

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (s) => s.name == _toCamelCase(value),
      orElse: () => BookingStatus.created,
    );
  }

  static String _toCamelCase(String s) {
    final parts = s.split('_');
    return parts.first + parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
  }

  String get displayLabel {
    return switch (this) {
      created => 'Created',
      vendorRequested => 'Finding Expert',
      vendorAccepted => 'Expert Assigned',
      paymentPending => 'Payment Pending',
      confirmed => 'Confirmed',
      serviceStarted => 'In Progress',
      serviceCompleted => 'Completed',
      cancelled => 'Cancelled',
    };
  }

  bool get isActive =>
      this == confirmed || this == serviceStarted || this == vendorAccepted;
  bool get isCompleted => this == serviceCompleted;
  bool get isCancelled => this == cancelled;
  bool get canCancel =>
      this == created || this == vendorRequested || this == confirmed;
  bool get canTrack =>
      this == vendorAccepted || this == confirmed || this == serviceStarted;
}

class BookingEntity extends Equatable {
  final String id;
  final String customerId;
  final String vendorId;
  final String serviceId;
  final String addressId;
  final BookingStatus status;
  final double totalAmount;
  final double taxAmount;
  final double vendorEarnings;
  final DateTime scheduledAt;
  final String notes;
  final String completionCode;
  final String cancellationReason;
  final double latitude;
  final double longitude;
  final DateTime? createdAt;

  // Populated from joins (not always present)
  final String? serviceName;
  final String? vendorName;
  final String? vendorAvatarUrl;
  final double? vendorRating;

  const BookingEntity({
    required this.id,
    required this.customerId,
    required this.vendorId,
    required this.serviceId,
    required this.addressId,
    required this.status,
    required this.totalAmount,
    required this.taxAmount,
    required this.vendorEarnings,
    required this.scheduledAt,
    required this.notes,
    required this.completionCode,
    required this.cancellationReason,
    required this.latitude,
    required this.longitude,
    this.createdAt,
    this.serviceName,
    this.vendorName,
    this.vendorAvatarUrl,
    this.vendorRating,
  });

  @override
  List<Object?> get props => [id, status, scheduledAt];
}
