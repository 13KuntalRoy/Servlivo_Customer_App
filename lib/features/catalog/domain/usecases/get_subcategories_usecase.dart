import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/catalog_repository.dart';

class GetSubcategoriesUseCase {
  final CatalogRepository _repository;
  GetSubcategoriesUseCase(this._repository);

  Future<Either<Failure, List<SubcategoryEntity>>> call(String categoryId) =>
      _repository.getSubcategories(categoryId);
}
