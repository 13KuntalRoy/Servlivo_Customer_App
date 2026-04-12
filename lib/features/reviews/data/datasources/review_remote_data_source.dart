import 'package:dio/dio.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/error/exceptions.dart';

abstract class ReviewRemoteDataSource {
  Future<Map<String, dynamic>> postReview(Map<String, dynamic> body);
  Future<List<Map<String, dynamic>>> getVendorReviews(String vendorId);
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final Dio dio;
  ReviewRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> postReview(Map<String, dynamic> body) async {
    try {
      final response = await dio.post(Endpoints.reviews, data: body);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleError(e, 'Failed to post review');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getVendorReviews(String vendorId) async {
    try {
      final response = await dio.get(Endpoints.vendorReviews(vendorId));
      final list = (response.data as List?) ?? [];
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _handleError(e, 'Failed to load reviews');
    }
  }

  Never _handleError(DioException e, String fallback) {
    final data = e.response?.data;
    final message = (data?['error']?['message'] ?? data?['message']) as String? ??
        e.message ?? fallback;
    throw ServerException(message: message, statusCode: e.response?.statusCode);
  }
}
