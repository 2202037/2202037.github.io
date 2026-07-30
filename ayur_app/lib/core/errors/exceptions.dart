class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([String message = 'No internet connection'])
      : super(message, statusCode: 0);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Unauthorized. Please login again.'])
      : super(message, statusCode: 401);
}

class ForbiddenException extends AppException {
  const ForbiddenException([String message = 'Access denied'])
      : super(message, statusCode: 403);
}

class NotFoundException extends AppException {
  const NotFoundException([String message = 'Resource not found'])
      : super(message, statusCode: 404);
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException(String message, {this.errors})
      : super(message, statusCode: 422);
}

class ServerException extends AppException {
  const ServerException([String message = 'Server error. Please try again.'])
      : super(message, statusCode: 500);
}

class TimeoutException extends AppException {
  const TimeoutException([String message = 'Request timed out. Please try again.'])
      : super(message);
}

class CacheException extends AppException {
  const CacheException([String message = 'Cache error'])
      : super(message);
}
