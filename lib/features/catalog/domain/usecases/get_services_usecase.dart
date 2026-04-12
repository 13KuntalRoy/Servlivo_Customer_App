import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/catalog_repository.dart';

class GetServicesUseCase {
  final CatalogRepository _repository;
  GetServicesUseCase(this._repository);

  Future<Either<Failure, List<ServiceEntity>>> call(String subcategoryId) =>
      _repository.getServices(subcategoryId);
}
