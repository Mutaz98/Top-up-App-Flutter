import 'package:dartz/dartz.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/features/user/domain/entities/user.dart';

abstract class IUserRepository {
  Future<Either<Failure, User>> getUser();
  Future<Either<Failure, User>> updateUser(User user);
}
