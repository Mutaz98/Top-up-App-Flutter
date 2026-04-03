class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'A server error occurred']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'A cache error occurred']);
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}

class BusinessRuleException implements Exception {
  final String message;
  const BusinessRuleException(this.message);
}
