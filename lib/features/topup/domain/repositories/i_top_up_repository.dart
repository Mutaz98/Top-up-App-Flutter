import 'package:dartz/dartz.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/features/topup/domain/entities/top_up_transaction.dart';

abstract class ITopUpRepository {
  Future<Either<Failure, TopUpTransaction>> executeTopUp({
    required String beneficiaryId,
    required double amount,
  });

  Future<Either<Failure, List<TopUpTransaction>>> getPendingTopUps();
  Future<Either<Failure, void>> syncPendingTopUps();
}
