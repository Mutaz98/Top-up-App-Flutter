import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:topup/core/errors/failures.dart';

abstract class UseCase<Type, Params> {
  const UseCase();
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();
  @override
  List<Object> get props => [];
}
