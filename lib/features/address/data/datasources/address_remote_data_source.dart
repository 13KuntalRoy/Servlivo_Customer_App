import 'package:dio/dio.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/address_model.dart';

abstract interface class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> createAddress(Map<String, dynamic> data);
  Future<void> updateAddress({required String id, required Map<String, dynamic> data});
  Future<void> deleteAddress(String id);
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  final Dio _dio;
  AddressRemoteDataSourceImpl(this._dio);

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _dio.get(Endpoints.addresses);
      final list = (response.data as List<dynamic>?) ?? [];
      return list.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<AddressModel> createAddress(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(Endpoints.addAddress, data: data);
      return AddressModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> updateAddress({required String id, required Map<String, dynamic> data}) async {
    try {
      await _dio.put(Endpoints.addressById(id), data: data);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    try {
      await _dio.delete(Endpoints.addressById(id));
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Never _handleError(DioException e) {
    final data = e.response?.data;
    final message = (data?['error']?['message'] ?? data?['message']) as String? ?? e.message ?? 'Error';
    throw ServerException(message: message, statusCode: e.response?.statusCode);
  }
}
