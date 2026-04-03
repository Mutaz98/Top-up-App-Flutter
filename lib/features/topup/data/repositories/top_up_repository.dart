import 'package:dartz/dartz.dart';
import 'package:topup/core/constants/app_constants.dart';
import 'package:topup/core/errors/exceptions.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/core/network/connectivity_service.dart';
import 'package:topup/features/topup/data/datasources/top_up_local_datasource.dart';
import 'package:topup/features/topup/data/datasources/top_up_remote_datasource.dart';
import 'package:topup/features/topup/data/models/pending_top_up_hive_model.dart';
import 'package:topup/features/topup/domain/entities/top_up_transaction.dart';
import 'package:topup/features/topup/domain/repositories/i_top_up_repository.dart';

class TopUpRepositoryImpl implements ITopUpRepository {
  final TopUpRemoteDataSource remoteDataSource;
  final TopUpLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  const TopUpRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, TopUpTransaction>> executeTopUp({
    required String beneficiaryId,
    required double amount,
  }) async {
    if (await connectivityService.isConnected) {
      try {
        final txn = await remoteDataSource.executeTopUp(
          beneficiaryId: beneficiaryId,
          amount: amount,
          fee: AppConstants.transactionFee,
        );
        return Right(txn.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      // Queue for later
      try {
        await localDataSource.enqueuePendingTopUp(PendingTopUpHiveModel(
          beneficiaryId: beneficiaryId,
          amount: amount,
          timestamp: DateTime.now().toIso8601String(),
        ));
        // Return a synthetic queued transaction so the UI can react
        final queued = TopUpTransaction(
          transactionId: 'queued_${DateTime.now().millisecondsSinceEpoch}',
          beneficiaryId: beneficiaryId,
          amount: amount,
          fee: AppConstants.transactionFee,
          timestamp: DateTime.now(),
        );
        return Right(queued);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<TopUpTransaction>>> getPendingTopUps() async {
    try {
      final pending = localDataSource.getPendingTopUps();
      final transactions = pending
          .map((p) => TopUpTransaction(
                transactionId: 'queued_${p.timestamp}',
                beneficiaryId: p.beneficiaryId,
                amount: p.amount,
                fee: AppConstants.transactionFee,
                timestamp: DateTime.parse(p.timestamp),
              ))
          .toList();
      return Right(transactions);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> syncPendingTopUps() async {
    if (!await connectivityService.isConnected) {
      return const Left(NetworkFailure('Cannot sync — no internet connection'));
    }
    try {
      final pending = localDataSource.getPendingTopUps();
      for (final p in pending) {
        await remoteDataSource.executeTopUp(
          beneficiaryId: p.beneficiaryId,
          amount: p.amount,
          fee: AppConstants.transactionFee,
        );
      }
      await localDataSource.clearPendingTopUps();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
