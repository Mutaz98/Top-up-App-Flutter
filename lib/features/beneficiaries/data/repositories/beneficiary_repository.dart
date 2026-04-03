import 'package:dartz/dartz.dart';
import 'package:topup/core/errors/exceptions.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/core/network/connectivity_service.dart';
import 'package:topup/features/beneficiaries/data/datasources/beneficiary_local_datasource.dart';
import 'package:topup/features/beneficiaries/data/datasources/beneficiary_remote_datasource.dart';
import 'package:topup/features/beneficiaries/data/models/beneficiary_model.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:topup/features/beneficiaries/domain/repositories/i_beneficiary_repository.dart';

class BeneficiaryRepositoryImpl implements IBeneficiaryRepository {
  final BeneficiaryRemoteDataSource remoteDataSource;
  final BeneficiaryLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  const BeneficiaryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, List<Beneficiary>>> getBeneficiaries() async {
    if (await connectivityService.isConnected) {
      try {
        final models = await remoteDataSource.getBeneficiaries();
        await localDataSource
            .cacheBeneficiaries(models.map((m) => m.toHiveModel()).toList());
        return Right(models.map((m) => m.toEntity()).toList());
      } on ServerException catch (e) {
        return _fromCache(e.message);
      }
    } else {
      return _fromCache('No internet connection');
    }
  }

  @override
  Future<Either<Failure, Beneficiary>> getBeneficiaryById(String id) async {
    final result = await getBeneficiaries();
    return result.fold(
      (failure) => Left(failure),
      (list) {
        try {
          final found = list.firstWhere((b) => b.id == id);
          return Right(found);
        } catch (_) {
          return const Left(
              ServerFailure('Beneficiary not found'));
        }
      },
    );
  }

  @override
  Future<Either<Failure, Beneficiary>> addBeneficiary(
      Beneficiary beneficiary) async {
    final model = BeneficiaryModel.fromEntity(beneficiary);

    // Optimistic local write first
    try {
      await localDataSource.addBeneficiary(model.toHiveModel());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }

    // Sync to remote if online
    if (await connectivityService.isConnected) {
      try {
        final remote = await remoteDataSource.addBeneficiary(model);
        return Right(remote.toEntity());
      } on ServerException {
        // Already saved locally — return local version
        return Right(beneficiary);
      }
    }
    return Right(beneficiary);
  }

  @override
  Future<Either<Failure, void>> deleteBeneficiary(String id) async {
    // Optimistic local delete
    try {
      await localDataSource.deleteBeneficiary(id);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }

    if (await connectivityService.isConnected) {
      try {
        await remoteDataSource.deleteBeneficiary(id);
      } on ServerException {
        // Deleted locally — tolerate remote failure silently
      }
    }
    return const Right(null);
  }

  Either<Failure, List<Beneficiary>> _fromCache(String remoteError) {
    try {
      final cached = localDataSource.getCachedBeneficiaries();
      return Right(cached.map((m) => m.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
