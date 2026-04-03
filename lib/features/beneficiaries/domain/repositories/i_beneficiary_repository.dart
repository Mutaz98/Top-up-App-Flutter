import 'package:dartz/dartz.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';

abstract class IBeneficiaryRepository {
  Future<Either<Failure, List<Beneficiary>>> getBeneficiaries();
  Future<Either<Failure, Beneficiary>> getBeneficiaryById(String id);
  Future<Either<Failure, Beneficiary>> addBeneficiary(Beneficiary beneficiary);
  Future<Either<Failure, void>> deleteBeneficiary(String id);
}
