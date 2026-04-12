import 'package:dio/dio.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/error/exceptions.dart';

abstract class WalletRemoteDataSource {
  Future<Map<String, dynamic>> getBalance();
  Future<List<Map<String, dynamic>>> getTransactions();
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final Dio dio;
  WalletRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getBalance() async {
    try {
      final response = await dio.get(Endpoints.wallet);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e, 'Failed to load wallet');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final response = await dio.get(Endpoints.walletTransactions);
      final list = (response.data as List?) ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _handleError(e, 'Failed to load transactions');
    }
  }

  Never _handleError(DioException e, String fallback) {
    final data = e.response?.data;
    final message = (data?['error']?['message'] ?? data?['message']) as String? ??
        e.message ?? fallback;
    throw ServerException(message: message, statusCode: e.response?.statusCode);
  }
}
