import 'package:dartz/dartz.dart';
import 'package:topup/core/errors/exceptions.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/core/network/connectivity_service.dart';
import 'package:topup/features/user/data/datasources/user_local_datasource.dart';
import 'package:topup/features/user/data/datasources/user_remote_datasource.dart';
import 'package:topup/features/user/data/models/user_hive_model.dart';
import 'package:topup/features/user/domain/entities/user.dart';
import 'package:topup/features/user/domain/repositories/i_user_repository.dart';

class UserRepositoryImpl implements IUserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  const UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, User>> getUser() async {
    if (await connectivityService.isConnected) {
      try {
        final userModel = await remoteDataSource.getUser();
        await localDataSource.cacheUser(userModel.toHiveModel());
        return Right(userModel.toEntity());
      } on ServerException catch (e) {
        return _fromCache(e.message);
      }
    } else {
      return _fromCache('No internet connection');
    }
  }

  @override
  Future<Either<Failure, User>> updateUser(User user) async {
    try {
      final hiveModel = UserHiveModel(
        id: user.id,
        name: user.name,
        balance: user.balance,
        isVerified: user.isVerified,
        monthlyTopUpTotal: user.monthlyTopUpTotal,
      );
      await localDataSource.cacheUser(hiveModel);
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  Either<Failure, User> _fromCache(String remoteError) {
    try {
      final cached = localDataSource.getCachedUser();
      if (cached != null) return Right(cached.toEntity());
      return Left(NetworkFailure(remoteError));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
