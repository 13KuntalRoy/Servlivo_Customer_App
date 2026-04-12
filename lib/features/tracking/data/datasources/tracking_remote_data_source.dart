import 'package:dio/dio.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/error/exceptions.dart';

abstract interface class TrackingRemoteDataSource {
  Future<Map<String, dynamic>> getVendorLocation(String vendorId);
}

class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSource {
  final Dio _dio;
  TrackingRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getVendorLocation(String vendorId) async {
    try {
      final response = await _dio.get(Endpoints.vendorLocation(vendorId));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] as String? ?? e.message ?? 'Error';
      throw ServerException(message: message, statusCode: e.response?.statusCode);
    }
  }
}
