import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource remote;
  final NetworkInfo networkInfo;

  CatalogRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final list = await remote.getCategories();
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<SubcategoryEntity>>> getSubcategories(String categoryId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final list = await remote.getSubcategories(categoryId);
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServices(String subcategoryId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final list = await remote.getServices(subcategoryId);
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ServiceEntity>> getServiceDetail(String serviceId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final model = await remote.getServiceDetail(serviceId);
      return Right(model);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ServiceAttributeEntity>>> getServiceAttributes(String serviceId) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final list = await remote.getServiceAttributes(serviceId);
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> searchServices({required String query, String? categoryId}) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final list = await remote.searchServices(query: query, categoryId: categoryId);
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAvailability({required String serviceId, required String date}) async {
    if (!await networkInfo.isConnected) return const Left(NetworkFailure('No internet'));
    try {
      final data = await remote.getAvailability(serviceId: serviceId, date: date);
      return Right(data);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
