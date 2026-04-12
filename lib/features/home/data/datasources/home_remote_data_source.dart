import 'package:dio/dio.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/error/exceptions.dart';

abstract class HomeRemoteDataSource {
  Future<Map<String, dynamic>> getHomeData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;
  HomeRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getHomeData() async {
    try {
      // Parallel fetch: categories + popular services
      final results = await Future.wait([
        dio.get(Endpoints.categories),
        dio.get(Endpoints.catalogServices,
            queryParameters: {'sort': 'popular', 'limit': 10}),
        dio.get(Endpoints.bookings, queryParameters: {'status': 'ongoing'}),
      ]);

      return {
        'categories': results[0].data,
        'popular_services': results[1].data,
        'ongoing_bookings': results[2].data,
      };
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data?['error']?['message'] ?? data?['message']) as String? ??
          e.message ?? 'Failed to load home data';
      throw ServerException(message: message, statusCode: e.response?.statusCode);
    }
  }
}
