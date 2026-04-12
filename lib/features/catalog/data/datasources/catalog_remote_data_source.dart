import 'package:dio/dio.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/catalog_models.dart';

abstract interface class CatalogRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<SubcategoryModel>> getSubcategories(String categoryId);
  Future<List<ServiceModel>> getServices(String subcategoryId);
  Future<ServiceModel> getServiceDetail(String serviceId);
  Future<List<ServiceAttributeModel>> getServiceAttributes(String serviceId);
  Future<List<ServiceModel>> searchServices({required String query, String? categoryId});
  Future<Map<String, dynamic>> getAvailability({required String serviceId, required String date});
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  final Dio _dio;
  CatalogRemoteDataSourceImpl(this._dio);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get(Endpoints.categories);
      final list = (response.data as List<dynamic>?) ?? [];
      return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<List<SubcategoryModel>> getSubcategories(String categoryId) async {
    try {
      final response = await _dio.get(Endpoints.subcategoriesByCat(categoryId));
      final list = (response.data as List<dynamic>?) ?? [];
      return list.map((e) => SubcategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<List<ServiceModel>> getServices(String subcategoryId) async {
    try {
      final response = await _dio.get(Endpoints.servicesBySubcat(subcategoryId));
      final list = (response.data as List<dynamic>?) ?? [];
      return list.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<ServiceModel> getServiceDetail(String serviceId) async {
    try {
      final response = await _dio.get(Endpoints.serviceById(serviceId));
      return ServiceModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<List<ServiceAttributeModel>> getServiceAttributes(String serviceId) async {
    try {
      final response = await _dio.get(Endpoints.serviceAttributes(serviceId));
      final list = (response.data as List<dynamic>?) ?? [];
      return list.map((e) => ServiceAttributeModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<List<ServiceModel>> searchServices({required String query, String? categoryId}) async {
    try {
      final params = <String, String>{'q': query};
      if (categoryId != null) params['category_id'] = categoryId;
      final response = await _dio.get(Endpoints.catalogSearch, queryParameters: params);
      final list = (response.data as List<dynamic>?) ?? [];
      return list.map((e) => ServiceModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getAvailability({required String serviceId, required String date}) async {
    try {
      final response = await _dio.get(
        Endpoints.catalogAvailability,
        queryParameters: {'service_id': serviceId, 'date': date},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Never _handleError(DioException e) {
    final data = e.response?.data;
    final message = (data?['error']?['message'] ?? data?['message']) as String? ??
        e.message ?? 'Error';
    throw ServerException(message: message, statusCode: e.response?.statusCode);
  }
}
