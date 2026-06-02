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
      // Public content loads first; bookings are optional so guest entry still works.
      final results = await Future.wait([
        dio.get(Endpoints.categories),
        dio.get(
          Endpoints.catalogServices,
          queryParameters: {'sort': 'popular', 'limit': 10},
        ),
      ]);

      // Backend returns the user's bookings as a JSON array (newest first);
      // the repository picks the most relevant one to surface on home.
      dynamic bookingsData;
      try {
        final bookingsResponse = await dio.get(Endpoints.bookings);
        bookingsData = bookingsResponse.data;
      } catch (_) {
        bookingsData = null;
      }

      return {
        'categories': results[0].data,
        'popular_services': results[1].data,
        'ongoing_bookings': bookingsData ?? const <dynamic>[],
      };
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data?['error']?['message'] ?? data?['message']) as String? ??
          e.message ?? 'Failed to load home data';
      throw ServerException(message: message, statusCode: e.response?.statusCode);
    }
  }
}
