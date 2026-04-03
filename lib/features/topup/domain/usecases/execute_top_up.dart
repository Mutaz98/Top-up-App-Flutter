import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:topup/core/constants/app_constants.dart';
import 'package:topup/core/errors/failures.dart';
import 'package:topup/core/usecases/usecase.dart';
import 'package:topup/features/beneficiaries/domain/repositories/i_beneficiary_repository.dart';
import 'package:topup/features/topup/domain/entities/top_up_transaction.dart';
import 'package:topup/features/topup/domain/repositories/i_top_up_repository.dart';
import 'package:topup/features/user/domain/repositories/i_user_repository.dart';

class ExecuteTopUpParams extends Equatable {
  final String beneficiaryId;
  final double amount;

  const ExecuteTopUpParams({
    required this.beneficiaryId,
    required this.amount,
  });

  @override
  List<Object> get props => [beneficiaryId, amount];
}

class ExecuteTopUp implements UseCase<TopUpTransaction, ExecuteTopUpParams> {
  final ITopUpRepository topUpRepository;
  final IUserRepository userRepository;
  final IBeneficiaryRepository beneficiaryRepository;

  const ExecuteTopUp({
    required this.topUpRepository,
    required this.userRepository,
    required this.beneficiaryRepository,
  });

  @override
  Future<Either<Failure, TopUpTransaction>> call(
      ExecuteTopUpParams params) async {
    // 1. Validate amount is an allowed option
    if (!AppConstants.topUpAmounts.contains(params.amount)) {
      return const Left(ValidationFailure('Invalid top-up amount selected'));
    }

    // 2. Get user
    final userResult = await userRepository.getUser();
    if (userResult.isLeft()) return Left(_extractFailure(userResult));
    final user = (userResult as Right).value;

    // 3. Balance check (amount + fee)
    final totalCost = params.amount + AppConstants.transactionFee;
    if (user.balance < totalCost) {
      return Left(BusinessRuleFailure(
          'Insufficient balance. Need AED ${totalCost.toStringAsFixed(2)} '
          '(AED ${params.amount.toStringAsFixed(0)} + AED ${AppConstants.transactionFee.toStringAsFixed(0)} fee)'));
    }

    // 4. Get beneficiary
    final benResult =
        await beneficiaryRepository.getBeneficiaryById(params.beneficiaryId);
    if (benResult.isLeft()) return Left(_extractFailure(benResult));
    final beneficiary = (benResult as Right).value;

    // 5. Per-beneficiary monthly limit
    final perBenLimit = user.isVerified
        ? AppConstants.verifiedMonthlyLimitPerBeneficiary
        : AppConstants.unverifiedMonthlyLimitPerBeneficiary;

    if (beneficiary.monthlyTopUpTotal + params.amount > perBenLimit) {
      final remaining = perBenLimit - beneficiary.monthlyTopUpTotal;
      return Left(BusinessRuleFailure(
          'Monthly limit exceeded for ${beneficiary.nickname}. '
          'Remaining: AED ${remaining.toStringAsFixed(0)} of AED ${perBenLimit.toStringAsFixed(0)}'));
    }

    // 6. Total monthly limit across all beneficiaries
    if (user.monthlyTopUpTotal + params.amount > AppConstants.totalMonthlyLimit) {
      final remaining =
          AppConstants.totalMonthlyLimit - user.monthlyTopUpTotal;
      return Left(BusinessRuleFailure(
          'Total monthly limit of AED ${AppConstants.totalMonthlyLimit.toStringAsFixed(0)} exceeded. '
          'Remaining: AED ${remaining.toStringAsFixed(0)}'));
    }

    // 7. Execute
    return topUpRepository.executeTopUp(
      beneficiaryId: params.beneficiaryId,
      amount: params.amount,
    );
  }

  Failure _extractFailure(Either<Failure, dynamic> either) =>
      either.fold((f) => f, (_) => const ServerFailure());
}
