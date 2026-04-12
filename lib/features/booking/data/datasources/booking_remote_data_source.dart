import 'package:dio/dio.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/booking_model.dart';

abstract interface class BookingRemoteDataSource {
  Future<BookingModel> createBooking(Map<String, dynamic> data);
  Future<List<BookingModel>> getBookings({String? status});
  Future<BookingModel> getBookingDetail(String id);
  Future<void> cancelBooking({required String id, required String reason});
  Future<void> rescheduleBooking({required String id, required String newTime});
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio _dio;
  BookingRemoteDataSourceImpl(this._dio);

  @override
  Future<BookingModel> createBooking(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(Endpoints.bookings, data: data);
      final bookingData = response.data['booking'] as Map<String, dynamic>? ?? response.data;
      return BookingModel.fromJson(bookingData);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<List<BookingModel>> getBookings({String? status}) async {
    try {
      final response = await _dio.get(
        Endpoints.bookings,
        queryParameters: status != null ? {'status': status} : null,
      );
      final list = (response.data as List<dynamic>?) ?? [];
      return list.map((e) => BookingModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<BookingModel> getBookingDetail(String id) async {
    try {
      final response = await _dio.get(Endpoints.bookingById(id));
      return BookingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> cancelBooking({required String id, required String reason}) async {
    try {
      await _dio.post(Endpoints.cancelBooking(id), data: {'reason': reason});
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> rescheduleBooking({required String id, required String newTime}) async {
    try {
      await _dio.post(Endpoints.rescheduleBooking(id), data: {'new_time': newTime});
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
