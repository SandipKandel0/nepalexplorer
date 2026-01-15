import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable{
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}
  

//local database failure
class LocalDatabaseFailure extends Failure{
  const LocalDatabaseFailure({
    String message = 'Local database operation is failed',
  }) :super(message);
}

//API Failure with status code
class ApiFailure extends Failure{
  final int? statusCode;

  const ApiFailure({
    required String message,
    this.statusCode
  }):super(message);

  @override
  List<Object?> get props => [message, statusCode];
}
// step1 create hive
// step2: create failure class
// step3: create Entity class
//step4: Repository(Domain layer)