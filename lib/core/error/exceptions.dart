abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class ServerException extends AppException {
  final int? statusCode;

  const ServerException({required super.message, super.code, this.statusCode});

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class CacheException extends AppException {
  const CacheException({required super.message, super.code});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code = 'NETWORK_ERROR',
  });

  @override
  String toString() => 'NetworkException: $message';
}
