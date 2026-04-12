import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remote;
  final NetworkInfo networkInfo;

  BookingRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  Future<Either<Failure, BookingEntity>> createBooking({
    required String serviceId,
    required String addressId,
    required DateTime scheduledAt,
    required double amount,
    String? notes,
    double? customerLat,
    double? customerLon,
    String? couponCode,
  }) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final model = await remote.createBooking({
        'service_id': serviceId,
        'address_id': addressId,
        'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        'amount': amount,
        if (notes != null) 'notes': notes,
        if (customerLat != null) 'customer_lat': customerLat,
        if (customerLon != null) 'customer_lon': customerLon,
        if (couponCode != null) 'coupon_code': couponCode,
      });
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getBookings({String? status}) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final list = await remote.getBookings(status: status);
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> getBookingDetail(String id) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final model = await remote.getBookingDetail(id);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking({required String id, required String reason}) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      await remote.cancelBooking(id: id, reason: reason);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> rescheduleBooking({required String id, required DateTime newTime}) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      await remote.rescheduleBooking(id: id, newTime: newTime.toUtc().toIso8601String());
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
