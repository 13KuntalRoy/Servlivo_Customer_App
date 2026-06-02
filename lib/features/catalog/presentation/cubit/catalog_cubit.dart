import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_service_attributes_usecase.dart';
import '../../domain/usecases/get_service_detail_usecase.dart';
import '../../domain/usecases/get_services_usecase.dart';
import '../../domain/usecases/get_subcategories_usecase.dart';
import '../../domain/usecases/search_services_usecase.dart';

part 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  final GetCategoriesUseCase _getCategories;
  final GetSubcategoriesUseCase _getSubcategories;
  final GetServicesUseCase _getServices;
  final GetServiceDetailUseCase _getServiceDetail;
  final GetServiceAttributesUseCase _getServiceAttributes;
  final SearchServicesUseCase _searchServices;

  CatalogCubit({
    required GetCategoriesUseCase getCategories,
    required GetSubcategoriesUseCase getSubcategories,
    required GetServicesUseCase getServices,
    required GetServiceDetailUseCase getServiceDetail,
    required GetServiceAttributesUseCase getServiceAttributes,
    required SearchServicesUseCase searchServices,
  })  : _getCategories = getCategories,
        _getSubcategories = getSubcategories,
        _getServices = getServices,
        _getServiceDetail = getServiceDetail,
        _getServiceAttributes = getServiceAttributes,
        _searchServices = searchServices,
        super(const CatalogInitial());

  Future<void> loadCategories() async {
    emit(const CatalogLoading());
    final result = await _getCategories();
    result.fold(
      (f) => emit(CatalogError(f.message)),
      (cats) => emit(CategoriesLoaded(cats)),
    );
  }

  Future<void> loadSubcategories(String categoryId) async {
    emit(const CatalogLoading());
    final result = await _getSubcategories(categoryId);
    result.fold(
      (f) => emit(CatalogError(f.message)),
      (subs) => emit(SubcategoriesLoaded(subs)),
    );
  }

  Future<void> loadServices(String subcategoryId) async {
    emit(const CatalogLoading());
    final result = await _getServices(subcategoryId);
    result.fold(
      (f) => emit(CatalogError(f.message)),
      (services) => emit(ServicesLoaded(services)),
    );
  }

  Future<void> loadServiceDetail(String serviceId) async {
    emit(const CatalogLoading());
    // Load the service and its configurable attributes together.
    final results = await Future.wait([
      _getServiceDetail(serviceId),
      _getServiceAttributes(serviceId),
    ]);
    final serviceRes = results[0] as Either<Failure, ServiceEntity>;
    final attrsRes = results[1] as Either<Failure, List<ServiceAttributeEntity>>;

    serviceRes.fold(
      (f) => emit(CatalogError(f.message)),
      (service) {
        // Attributes are optional — never fail the page if they don't load.
        final attrs = attrsRes.fold((_) => <ServiceAttributeEntity>[], (a) => a);
        emit(ServiceDetailLoaded(service, attributes: attrs));
      },
    );
  }

  Future<void> searchServices({required String query, String? categoryId}) async {
    if (query.trim().isEmpty) {
      emit(const CatalogInitial());
      return;
    }
    emit(const CatalogLoading());
    final result = await _searchServices(SearchParams(query: query, categoryId: categoryId));
    result.fold(
      (f) => emit(CatalogError(f.message)),
      (services) => emit(ServicesLoaded(services)),
    );
  }
}
