import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.customerId,
    required super.vendorId,
    required super.serviceId,
    required super.addressId,
    required super.status,
    required super.totalAmount,
    required super.taxAmount,
    required super.vendorEarnings,
    required super.scheduledAt,
    required super.notes,
    required super.completionCode,
    required super.cancellationReason,
    required super.latitude,
    required super.longitude,
    super.createdAt,
    super.serviceName,
    super.vendorName,
    super.vendorAvatarUrl,
    super.vendorRating,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json['id'] as String? ?? '',
        customerId: json['customer_id'] as String? ?? '',
        vendorId: json['vendor_id'] as String? ?? '',
        serviceId: json['service_id'] as String? ?? '',
        addressId: json['address_id'] as String? ?? '',
        status: BookingStatus.fromString(json['status'] as String? ?? 'created'),
        totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
        taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0,
        vendorEarnings: (json['vendor_earnings'] as num?)?.toDouble() ?? 0,
        scheduledAt: json['scheduled_at'] != null
            ? DateTime.parse(json['scheduled_at'] as String)
            : DateTime.now(),
        notes: json['notes'] as String? ?? '',
        completionCode: json['completion_code'] as String? ?? '',
        cancellationReason: json['cancellation_reason'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        // Joined fields — present in list/detail responses via API joins
        serviceName: json['service_name'] as String? ??
            (json['service'] as Map<String, dynamic>?)?['name'] as String?,
        vendorName: json['vendor_name'] as String? ??
            (json['vendor'] as Map<String, dynamic>?)?['name'] as String?,
        vendorAvatarUrl: json['vendor_avatar_url'] as String? ??
            (json['vendor'] as Map<String, dynamic>?)?['avatar_url'] as String?,
        vendorRating: (json['vendor_rating'] as num?)?.toDouble() ??
            ((json['vendor'] as Map<String, dynamic>?)?['rating'] as num?)?.toDouble(),
      );
}
