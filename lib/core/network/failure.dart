/// Sealed class representing domain-level failures from the network layer.
sealed class Failure {
  const Failure();
}

/// No internet connection or DNS resolution failure.
final class NetworkFailure extends Failure {
  const NetworkFailure();
}

/// The server returned a non-2xx HTTP status code.
final class ServerFailure extends Failure {
  final int statusCode;
  final String? message;

  const ServerFailure({required this.statusCode, this.message});
}

/// An unexpected error occurred (e.g. JSON parsing, timeout).
final class UnknownFailure extends Failure {
  final String message;

  const UnknownFailure(this.message);
}
