import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/booking_entity.dart';

abstract interface class BookingRepository {
  Future<Either<Failure, BookingEntity>> createBooking({
    required String serviceId,
    required String addressId,
    required DateTime scheduledAt,
    required double amount,
    String? notes,
    double? customerLat,
    double? customerLon,
    String? couponCode,
  });

  Future<Either<Failure, List<BookingEntity>>> getBookings({String? status});

  Future<Either<Failure, BookingEntity>> getBookingDetail(String id);

  Future<Either<Failure, void>> cancelBooking({
    required String id,
    required String reason,
  });

  Future<Either<Failure, void>> rescheduleBooking({
    required String id,
    required DateTime newTime,
  });
}
