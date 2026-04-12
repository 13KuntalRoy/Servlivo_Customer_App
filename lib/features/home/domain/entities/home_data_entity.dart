import 'package:equatable/equatable.dart';

import '../../../catalog/domain/entities/category_entity.dart';

class HomeDataEntity extends Equatable {
  final String greeting;
  final String? currentAddress;
  final bool hasPrimeMembership;
  final OngoingBookingSummary? ongoingBooking;
  final List<CategoryEntity> categories;
  final List<PopularServiceEntity> popularServices;

  const HomeDataEntity({
    required this.greeting,
    this.currentAddress,
    required this.hasPrimeMembership,
    this.ongoingBooking,
    required this.categories,
    required this.popularServices,
  });

  @override
  List<Object?> get props => [greeting, ongoingBooking, categories, popularServices];
}

class OngoingBookingSummary extends Equatable {
  final String bookingId;
  final String serviceName;
  final String vendorName;
  final String status;
  final DateTime scheduledAt;

  const OngoingBookingSummary({
    required this.bookingId,
    required this.serviceName,
    required this.vendorName,
    required this.status,
    required this.scheduledAt,
  });

  @override
  List<Object> get props => [bookingId, serviceName, status];
}

class PopularServiceEntity extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double rating;
  final String duration;
  final String categoryName;

  const PopularServiceEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.duration,
    required this.categoryName,
  });

  @override
  List<Object> get props => [id, name, price];
}
