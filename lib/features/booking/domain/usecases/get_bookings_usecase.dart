import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetBookingsUseCase {
  final BookingRepository _repository;
  GetBookingsUseCase(this._repository);

  Future<Either<Failure, List<BookingEntity>>> call({String? status}) =>
      _repository.getBookings(status: status);
}
