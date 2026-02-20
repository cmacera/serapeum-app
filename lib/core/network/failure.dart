/// Sealed class representing domain-level failures from the network layer.
sealed class Failure {
  const Failure();
}

/// No internet connection or DNS resolution failure.
final class NetworkFailure extends Failure {
  const NetworkFailure();
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkFailure && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'NetworkFailure()';
}

/// The server returned a non-2xx HTTP status code.
final class ServerFailure extends Failure {
  final int statusCode;
  final String? message;

  const ServerFailure({required this.statusCode, this.message});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerFailure &&
          runtimeType == other.runtimeType &&
          statusCode == other.statusCode &&
          message == other.message;

  @override
  int get hashCode => Object.hash(statusCode, message);

  @override
  String toString() =>
      'ServerFailure(statusCode: $statusCode, message: $message)';
}

/// A network request timed out (connect, send, or receive).
final class TimeoutFailure extends Failure {
  const TimeoutFailure();
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeoutFailure && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'TimeoutFailure()';
}

/// An unexpected error occurred (e.g. JSON parsing error, unknown Dio error).
final class UnknownFailure extends Failure {
  final String message;

  const UnknownFailure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownFailure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'UnknownFailure(message: $message)';
}
