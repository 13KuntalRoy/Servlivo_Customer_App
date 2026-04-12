import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/booking_repository.dart';

class RescheduleParams extends Equatable {
  final String id;
  final DateTime newTime;

  const RescheduleParams({required this.id, required this.newTime});

  @override
  List<Object> get props => [id, newTime];
}

class RescheduleBookingUseCase {
  final BookingRepository _repository;
  RescheduleBookingUseCase(this._repository);

  Future<Either<Failure, void>> call(RescheduleParams params) =>
      _repository.rescheduleBooking(id: params.id, newTime: params.newTime);
}
