import 'package:dio/dio.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/error/exceptions.dart';

abstract class PrimeRemoteDataSource {
  Future<List<Map<String, dynamic>>> getPlans();
  Future<Map<String, dynamic>> subscribe(String planId);
  Future<Map<String, dynamic>?> getMembership();
}

class PrimeRemoteDataSourceImpl implements PrimeRemoteDataSource {
  final Dio dio;
  PrimeRemoteDataSourceImpl(this.dio);

  @override
  Future<List<Map<String, dynamic>>> getPlans() async {
    try {
      final response = await dio.get(Endpoints.primePlans);
      final list = (response.data as List?) ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _handleError(e, 'Failed to load plans');
    }
  }

  @override
  Future<Map<String, dynamic>> subscribe(String planId) async {
    try {
      // Backend expects {"plan": "monthly"} or {"plan": "annual"} — not a UUID
      final response = await dio.post(Endpoints.primeSubscribe, data: {'plan': planId});
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e, 'Subscription failed');
    }
  }

  @override
  Future<Map<String, dynamic>?> getMembership() async {
    try {
      final response = await dio.get(Endpoints.primeMe);
      return response.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      _handleError(e, 'Failed to load membership');
    }
  }

  Never _handleError(DioException e, String fallback) {
    final data = e.response?.data;
    final message = (data?['error']?['message'] ?? data?['message']) as String? ??
        e.message ?? fallback;
    throw ServerException(message: message, statusCode: e.response?.statusCode);
  }
}
