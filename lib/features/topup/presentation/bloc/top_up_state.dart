import 'package:equatable/equatable.dart';
import 'package:topup/features/topup/domain/entities/top_up_transaction.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:topup/features/user/domain/entities/user.dart';
import 'package:topup/core/constants/app_constants.dart';

abstract class TopUpState extends Equatable {
  const TopUpState();
  @override
  List<Object?> get props => [];
}

class TopUpInitial extends TopUpState {
  const TopUpInitial();
}

class TopUpFormReady extends TopUpState {
  final User user;
  final Beneficiary beneficiary;
  final double? selectedAmount;

  const TopUpFormReady({
    required this.user,
    required this.beneficiary,
    this.selectedAmount,
  });

  TopUpFormReady copyWith({
    User? user,
    Beneficiary? beneficiary,
    double? selectedAmount,
  }) {
    return TopUpFormReady(
      user: user ?? this.user,
      beneficiary: beneficiary ?? this.beneficiary,
      selectedAmount: selectedAmount ?? this.selectedAmount,
    );
  }

  double get perBenLimit => user.isVerified
      ? AppConstants.verifiedMonthlyLimitPerBeneficiary
      : AppConstants.unverifiedMonthlyLimitPerBeneficiary;

  double get benRemaining => perBenLimit - beneficiary.monthlyTopUpTotal;

  double get totalRemaining =>
      AppConstants.totalMonthlyLimit - user.monthlyTopUpTotal;

  bool isAmountDisabled(double amount) {
    final totalCost = amount + AppConstants.transactionFee;
    return user.balance < totalCost ||
        amount > benRemaining ||
        amount > totalRemaining;
  }

  @override
  List<Object?> get props => [user, beneficiary, selectedAmount];
}

class TopUpLoading extends TopUpState {
  const TopUpLoading();
}

class TopUpSuccess extends TopUpState {
  final TopUpTransaction transaction;
  const TopUpSuccess(this.transaction);
  @override
  List<Object> get props => [transaction];
}

class TopUpQueued extends TopUpState {
  final TopUpTransaction transaction;
  const TopUpQueued(this.transaction);
  @override
  List<Object> get props => [transaction];
}

class TopUpSynced extends TopUpState {
  const TopUpSynced();
}

class TopUpError extends TopUpState {
  final String message;
  const TopUpError(this.message);
  @override
  List<Object> get props => [message];
}
