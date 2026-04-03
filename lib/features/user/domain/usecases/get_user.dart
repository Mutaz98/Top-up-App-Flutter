import 'package:dartz/dartz.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/core/usecases/usecase.dart';
import 'package:topup/features/user/domain/entities/user.dart';
import 'package:topup/features/user/domain/repositories/i_user_repository.dart';

class GetUser implements UseCase<User, NoParams> {
  final IUserRepository repository;

  const GetUser(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) =>
      repository.getUser();
}
