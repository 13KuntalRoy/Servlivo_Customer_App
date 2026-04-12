import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/catalog_repository.dart';

class AvailabilityParams extends Equatable {
  final String serviceId;
  final String date;

  const AvailabilityParams({required this.serviceId, required this.date});

  @override
  List<Object> get props => [serviceId, date];
}

class GetAvailabilityUseCase {
  final CatalogRepository _repository;
  GetAvailabilityUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call(AvailabilityParams params) =>
      _repository.getAvailability(serviceId: params.serviceId, date: params.date);
}
