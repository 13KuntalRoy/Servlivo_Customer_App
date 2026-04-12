import 'package:dio/dio.dart';

import '../../../../core/api/endpoints.dart';
import '../../../../core/error/exceptions.dart';

// Re-export model for use in repository
export '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<void> register({
    required String email,
    required String password,
    required String phone,
    required String name,
    String? referralCode,
  });

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  });

  Future<void> resendOtp({required String email});

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<void> sendPhoneOtp({required String phone});

  Future<Map<String, dynamic>> verifyPhoneOtp({
    required String phone,
    required String otp,
    String? name,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<void> register({
    required String email,
    required String password,
    required String phone,
    required String name,
    String? referralCode,
  }) async {
    try {
      await _dio.post(
        Endpoints.register,
        data: {
          'email': email,
          'password': password,
          'phone': phone,
          'name': name,
          'role': 'customer',
          if (referralCode != null && referralCode.isNotEmpty)
            'referral_code': referralCode,
        },
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        Endpoints.verifyOtp,
        data: {'email': email, 'otp': otp},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<void> resendOtp({required String email}) async {
    try {
      await _dio.post(Endpoints.resendOtp, data: {'email': email});
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        Endpoints.login,
        data: {'email': email, 'password': password},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dio.post(Endpoints.logout);
    } on DioException catch (e) {
      // Logout failures are non-critical — still clear local tokens
      if (e.response?.statusCode != 401) {
        _handleDioError(e);
      }
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post(Endpoints.forgotPassword, data: {'email': email});
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        Endpoints.resetPassword,
        data: {'email': email, 'otp': otp, 'new_password': newPassword},
      );
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<void> sendPhoneOtp({required String phone}) async {
    try {
      await _dio.post(Endpoints.phoneSendOtp, data: {'phone': phone});
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> verifyPhoneOtp({
    required String phone,
    required String otp,
    String? name,
  }) async {
    try {
      final response = await _dio.post(
        Endpoints.phoneVerifyOtp,
        data: {
          'phone': phone,
          'otp': otp,
          if (name != null && name.isNotEmpty) 'name': name,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Never _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      throw const UnauthorizedException();
    }
    final data = e.response?.data;
    final message = (data?['error']?['message'] ?? data?['message']) as String? ??
        e.message ??
        'Something went wrong';
    throw ServerException(
      message: message,
      statusCode: e.response?.statusCode,
    );
  }
}
