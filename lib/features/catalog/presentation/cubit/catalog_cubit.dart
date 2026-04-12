import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/get_availability_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
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
  final SearchServicesUseCase _searchServices;
  final GetAvailabilityUseCase _getAvailability;

  CatalogCubit({
    required GetCategoriesUseCase getCategories,
    required GetSubcategoriesUseCase getSubcategories,
    required GetServicesUseCase getServices,
    required GetServiceDetailUseCase getServiceDetail,
    required SearchServicesUseCase searchServices,
    required GetAvailabilityUseCase getAvailability,
  })  : _getCategories = getCategories,
        _getSubcategories = getSubcategories,
        _getServices = getServices,
        _getServiceDetail = getServiceDetail,
        _searchServices = searchServices,
        _getAvailability = getAvailability,
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
    final result = await _getServiceDetail(serviceId);
    result.fold(
      (f) => emit(CatalogError(f.message)),
      (service) => emit(ServiceDetailLoaded(service)),
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

  Future<void> loadAvailability({required String serviceId, required String date}) async {
    final result = await _getAvailability(AvailabilityParams(serviceId: serviceId, date: date));
    result.fold(
      (f) => emit(CatalogError(f.message)),
      (data) => emit(AvailabilityLoaded(
        available: data['available'] as bool? ?? false,
        slots: (data['slots'] as List<dynamic>?)?.cast<String>() ?? [],
      )),
    );
  }
}
