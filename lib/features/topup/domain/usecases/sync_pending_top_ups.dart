import 'package:dartz/dartz.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/core/usecases/usecase.dart';
import 'package:topup/features/topup/domain/repositories/i_top_up_repository.dart';

class SyncPendingTopUps extends UseCase<void, NoParams> {
  final ITopUpRepository repository;

  const SyncPendingTopUps(this.repository) : super();

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.syncPendingTopUps();
  }
}
