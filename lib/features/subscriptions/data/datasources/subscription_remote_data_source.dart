import 'package:dio/dio.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/error/exceptions.dart';

abstract class SubscriptionRemoteDataSource {
  Future<List<Map<String, dynamic>>> getSubscriptions();
  Future<Map<String, dynamic>> createSubscription(Map<String, dynamic> body);
  Future<Map<String, dynamic>> pauseSubscription(String id);
  Future<Map<String, dynamic>> resumeSubscription(String id);
  Future<void> cancelSubscription(String id);
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final Dio dio;
  SubscriptionRemoteDataSourceImpl(this.dio);

  @override
  Future<List<Map<String, dynamic>>> getSubscriptions() async {
    try {
      final response = await dio.get(Endpoints.subscriptions);
      final list = (response.data as List?) ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _handleError(e, 'Failed to load subscriptions');
    }
  }

  @override
  Future<Map<String, dynamic>> createSubscription(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(Endpoints.subscriptions, data: body);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e, 'Failed to create subscription');
    }
  }

  @override
  Future<Map<String, dynamic>> pauseSubscription(String id) async {
    try {
      final response = await dio.post(Endpoints.pauseSubscription(id));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e, 'Failed to pause subscription');
    }
  }

  @override
  Future<Map<String, dynamic>> resumeSubscription(String id) async {
    try {
      final response = await dio.post(Endpoints.resumeSubscription(id));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e, 'Failed to resume subscription');
    }
  }

  @override
  Future<void> cancelSubscription(String id) async {
    try {
      // Backend: POST /subscriptions/:id/cancel (not DELETE)
      await dio.post(Endpoints.cancelSubscription(id));
    } on DioException catch (e) {
      _handleError(e, 'Failed to cancel subscription');
    }
  }

  Never _handleError(DioException e, String fallback) {
    final data = e.response?.data;
    final message = (data?['error']?['message'] ?? data?['message']) as String? ??
        e.message ?? fallback;
    throw ServerException(message: message, statusCode: e.response?.statusCode);
  }
}
