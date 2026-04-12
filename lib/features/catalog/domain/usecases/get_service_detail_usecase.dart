import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/catalog_repository.dart';

class GetServiceDetailUseCase {
  final CatalogRepository _repository;
  GetServiceDetailUseCase(this._repository);

  Future<Either<Failure, ServiceEntity>> call(String serviceId) =>
      _repository.getServiceDetail(serviceId);
}
