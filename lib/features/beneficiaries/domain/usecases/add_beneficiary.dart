import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:topup/core/errors/failures.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/constants/app_constants.dart';
import '../entities/beneficiary.dart';
import '../repositories/i_beneficiary_repository.dart';

class AddBeneficiaryParams extends Equatable {
  final String nickname;
  final String phoneNumber;

  const AddBeneficiaryParams({
    required this.nickname,
    required this.phoneNumber,
  });

  @override
  List<Object> get props => [nickname, phoneNumber];
}

class AddBeneficiary implements UseCase<Beneficiary, AddBeneficiaryParams> {
  final IBeneficiaryRepository repository;

  const AddBeneficiary(this.repository);

  @override
  Future<Either<Failure, Beneficiary>> call(AddBeneficiaryParams params) async {
    final trimmedNickname = params.nickname.trim();

    // 1. Business Logic (Requires Repository)

    final result = await repository.getBeneficiaries();

    return result.fold(
      (failure) => Left(failure),
      (beneficiaries) async {
        if (beneficiaries.length >= AppConstants.maxBeneficiaries) {
          return Left(BusinessRuleFailure(
              'Maximum of ${AppConstants.maxBeneficiaries} beneficiaries allowed'));
        }

        // Rule: Unique phone numbers
        final duplicate =
            beneficiaries.any((b) => b.phoneNumber == params.phoneNumber);
        if (duplicate) {
          return const Left(
              BusinessRuleFailure('This phone number is already added'));
        }

        // 2. Execution
        final newBeneficiary = Beneficiary(
          id: 'ben_${DateTime.now().millisecondsSinceEpoch}',
          nickname: trimmedNickname,
          phoneNumber: params.phoneNumber,
          monthlyTopUpTotal: 0.0,
        );

        return await repository.addBeneficiary(newBeneficiary);
      },
    );
  }
}
