import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';

abstract interface class CatalogRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, List<SubcategoryEntity>>> getSubcategories(String categoryId);
  Future<Either<Failure, List<ServiceEntity>>> getServices(String subcategoryId);
  Future<Either<Failure, ServiceEntity>> getServiceDetail(String serviceId);
  Future<Either<Failure, List<ServiceAttributeEntity>>> getServiceAttributes(String serviceId);
  Future<Either<Failure, List<ServiceEntity>>> searchServices({required String query, String? categoryId});
  Future<Either<Failure, Map<String, dynamic>>> getAvailability({required String serviceId, required String date});
}
