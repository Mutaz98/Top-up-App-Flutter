import 'package:dartz/dartz.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/core/usecases/usecase.dart';
import 'package:topup/features/topup/domain/entities/top_up_transaction.dart';
import 'package:topup/features/topup/domain/repositories/i_top_up_repository.dart';

class GetPendingTopUps extends UseCase<List<TopUpTransaction>, NoParams> {
  final ITopUpRepository repository;

  const GetPendingTopUps(this.repository) : super();

  @override
  Future<Either<Failure, List<TopUpTransaction>>> call(NoParams params) async {
    return await repository.getPendingTopUps();
  }
}
