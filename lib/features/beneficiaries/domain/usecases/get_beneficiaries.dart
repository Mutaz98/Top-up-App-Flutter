import 'package:dartz/dartz.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/core/usecases/usecase.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:topup/features/beneficiaries/domain/repositories/i_beneficiary_repository.dart';

class GetBeneficiaries implements UseCase<List<Beneficiary>, NoParams> {
  final IBeneficiaryRepository repository;

  const GetBeneficiaries(this.repository);

  @override
  Future<Either<Failure, List<Beneficiary>>> call(NoParams params) =>
      repository.getBeneficiaries();
}
