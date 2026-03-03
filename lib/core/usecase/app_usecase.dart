import 'package:dartz/dartz.dart';
import 'package:nepalexplorer/core/error/failures.dart';

// Usecase with parameters
abstract interface class UsecaseWithParams<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

// Usecase without parameters
abstract interface class UsecaseWithoutParams<SuccessType> {
  Future<Either<Failure, SuccessType>> call();
}