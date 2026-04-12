import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/category_entity.dart';
import '../repositories/catalog_repository.dart';

class SearchParams extends Equatable {
  final String query;
  final String? categoryId;

  const SearchParams({required this.query, this.categoryId});

  @override
  List<Object?> get props => [query, categoryId];
}

class SearchServicesUseCase {
  final CatalogRepository _repository;
  SearchServicesUseCase(this._repository);

  Future<Either<Failure, List<ServiceEntity>>> call(SearchParams params) =>
      _repository.searchServices(query: params.query, categoryId: params.categoryId);
}
