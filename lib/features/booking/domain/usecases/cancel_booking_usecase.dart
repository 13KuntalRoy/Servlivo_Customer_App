import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/booking_repository.dart';

class CancelBookingParams extends Equatable {
  final String id;
  final String reason;

  const CancelBookingParams({required this.id, required this.reason});

  @override
  List<Object> get props => [id, reason];
}

class CancelBookingUseCase {
  final BookingRepository _repository;
  CancelBookingUseCase(this._repository);

  Future<Either<Failure, void>> call(CancelBookingParams params) =>
      _repository.cancelBooking(id: params.id, reason: params.reason);
}
