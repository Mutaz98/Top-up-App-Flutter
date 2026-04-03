import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/core/usecases/usecase.dart';
import 'package:topup/features/beneficiaries/domain/repositories/i_beneficiary_repository.dart';

class DeleteBeneficiaryParams extends Equatable {
  final String id;

  const DeleteBeneficiaryParams(this.id);

  @override
  List<Object> get props => [id];
}

class DeleteBeneficiary implements UseCase<void, DeleteBeneficiaryParams> {
  final IBeneficiaryRepository repository;

  const DeleteBeneficiary(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteBeneficiaryParams params) =>
      repository.deleteBeneficiary(params.id);
}
