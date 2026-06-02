import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/catalog_repository.dart';

class GetServiceAttributesUseCase {
  final CatalogRepository _repository;
  GetServiceAttributesUseCase(this._repository);

  Future<Either<Failure, List<ServiceAttributeEntity>>> call(String serviceId) =>
      _repository.getServiceAttributes(serviceId);
}
