

import 'package:equatable/equatable.dart';

/// ✅ Base Failure class
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// ✅ Local database failure
class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({
    String message = 'Local database operation failed',
  }) : super(message);
}

/// ✅ API failure with optional status code
class ApiFailure extends Failure {
  final int? statusCode;

  const ApiFailure({
    required String message,
    this.statusCode,
  }) : super(message);

  @override
  List<Object?> get props => [message, statusCode];
}

/// ✅ Network failure (no internet connection)
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'No internet connection',
  }) : super(message);
}

/// ✅ Authentication failure (optional, if needed separately)
class AuthFailure extends Failure {
  const AuthFailure({
    String message = 'Authentication failed',
  }) : super(message);
}

// step1 create hive
// step2: create failure class
// step3: create Entity class
//step4: Repository(Domain layer)