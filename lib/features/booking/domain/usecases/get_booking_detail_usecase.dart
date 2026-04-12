import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetBookingDetailUseCase {
  final BookingRepository _repository;
  GetBookingDetailUseCase(this._repository);

  Future<Either<Failure, BookingEntity>> call(String id) =>
      _repository.getBookingDetail(id);
}
