import 'package:dio/dio.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/error/exceptions.dart';

abstract class PaymentRemoteDataSource {
  Future<Map<String, dynamic>> initiatePayment(String bookingId);
  Future<Map<String, dynamic>> verifyPayment(Map<String, dynamic> body);
  Future<List<Map<String, dynamic>>> getTransactions();
  Future<Map<String, dynamic>> requestRefund(String paymentId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;
  PaymentRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> initiatePayment(String bookingId) async {
    try {
      final response = await dio.post(
        Endpoints.initiatePayment,
        data: {'booking_id': bookingId},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e, 'Payment initiation failed');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyPayment(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(Endpoints.verifyPayment, data: body);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e, 'Payment verification failed');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final response = await dio.get(Endpoints.transactions);
      final list = (response.data as List?) ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _handleError(e, 'Failed to load transactions');
    }
  }

  @override
  Future<Map<String, dynamic>> requestRefund(String paymentId) async {
    try {
      final response = await dio.post('${Endpoints.refund}/$paymentId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e, 'Refund request failed');
    }
  }

  Never _handleError(DioException e, String fallback) {
    final data = e.response?.data;
    final message = (data?['error']?['message'] ?? data?['message']) as String? ??
        e.message ?? fallback;
    throw ServerException(message: message, statusCode: e.response?.statusCode);
  }
}
