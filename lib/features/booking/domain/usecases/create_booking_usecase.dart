import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class CreateBookingParams extends Equatable {
  final String serviceId;
  final String addressId;
  final DateTime scheduledAt;
  final double amount;
  final String? notes;
  final double? customerLat;
  final double? customerLon;
  final String? couponCode;

  const CreateBookingParams({
    required this.serviceId,
    required this.addressId,
    required this.scheduledAt,
    required this.amount,
    this.notes,
    this.customerLat,
    this.customerLon,
    this.couponCode,
  });

  @override
  List<Object?> get props => [serviceId, addressId, scheduledAt, amount];
}

class CreateBookingUseCase {
  final BookingRepository _repository;
  CreateBookingUseCase(this._repository);

  Future<Either<Failure, BookingEntity>> call(CreateBookingParams params) =>
      _repository.createBooking(
        serviceId: params.serviceId,
        addressId: params.addressId,
        scheduledAt: params.scheduledAt,
        amount: params.amount,
        notes: params.notes,
        customerLat: params.customerLat,
        customerLon: params.customerLon,
        couponCode: params.couponCode,
      );
}
