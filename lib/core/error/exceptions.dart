class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  const NetworkException();

  @override
  String toString() => 'NetworkException: No internet connection';
}

class UnauthorizedException implements Exception {
  const UnauthorizedException();

  @override
  String toString() => 'UnauthorizedException: Invalid or expired credentials';
}

class TokenExpiredException implements Exception {
  const TokenExpiredException();

  @override
  String toString() => 'TokenExpiredException: Access token has expired';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException({required this.message});

  @override
  String toString() => 'NotFoundException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException({required this.message});

  @override
  String toString() => 'ValidationException: $message';
}
