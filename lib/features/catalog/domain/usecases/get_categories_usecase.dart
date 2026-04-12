import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/catalog_repository.dart';

class GetCategoriesUseCase {
  final CatalogRepository _repository;
  GetCategoriesUseCase(this._repository);

  Future<Either<Failure, List<CategoryEntity>>> call() => _repository.getCategories();
}
