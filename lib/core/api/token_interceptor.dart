import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';
import 'endpoints.dart';

class TokenInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorageService _storage;
  bool _isRefreshing = false;

  TokenInterceptor({
    required Dio dio,
    required SecureStorageService storage,
  })  : _dio = dio,
        _storage = storage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token injection for public auth endpoints
    if (_isAuthEndpoint(options.path)) {
      return handler.next(options);
    }

    final token = await _storage.read(
      key: SecureStorageServiceImpl.kAccessToken,
    );
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final newToken = await _refreshAccessToken();
        _isRefreshing = false;

        // Retry the original request with the new token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';
        final response = await _dio.fetch(opts);
        handler.resolve(response);
      } catch (_) {
        _isRefreshing = false;
        // Refresh failed — clear all tokens (force logout)
        await _storage.deleteAll();
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }

  Future<String> _refreshAccessToken() async {
    final refreshToken = await _storage.read(
      key: SecureStorageServiceImpl.kRefreshToken,
    );
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token available');
    }

    // Use a plain Dio instance (no interceptors) to avoid infinite recursion
    final refreshDio = Dio(
      BaseOptions(baseUrl: Endpoints.baseUrl),
    );

    final response = await refreshDio.post(
      Endpoints.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    final newAccess = response.data['access_token'] as String;
    final newRefresh = response.data['refresh_token'] as String;

    await _storage.saveTokens(
      accessToken: newAccess,
      refreshToken: newRefresh,
    );

    return newAccess;
  }

  bool _isAuthEndpoint(String path) {
    const publicPaths = [
      '/auth/register',
      '/auth/verify',
      '/auth/resend-otp',
      '/auth/login',
      '/auth/refresh',
      '/auth/forgot-password',
      '/auth/reset-password',
    ];
    return publicPaths.any((p) => path.endsWith(p));
  }
}
