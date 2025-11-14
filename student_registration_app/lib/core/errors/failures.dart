/// Base failure class for error handling
abstract class Failure {
  final String message;

  const Failure(this.message);
}

/// Server failure - when API returns an error
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

/// Network failure - when there's no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// Authentication failure - when token is invalid or expired
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

/// Validation failure - when input validation fails
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

/// Cache failure - when local storage fails
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}
