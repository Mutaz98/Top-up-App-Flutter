import 'package:equatable/equatable.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';
import 'package:topup/features/user/domain/entities/user.dart';

abstract class TopUpEvent extends Equatable {
  const TopUpEvent();
  @override
  List<Object?> get props => [];
}

class InitializeTopUpForm extends TopUpEvent {
  final User user;
  final Beneficiary beneficiary;
  const InitializeTopUpForm({required this.user, required this.beneficiary});
  @override
  List<Object> get props => [user, beneficiary];
}

class SelectTopUpAmount extends TopUpEvent {
  final double amount;
  const SelectTopUpAmount(this.amount);
  @override
  List<Object> get props => [amount];
}

class ExecuteTopUpEvent extends TopUpEvent {
  final String beneficiaryId;
  final double amount;
  const ExecuteTopUpEvent({required this.beneficiaryId, required this.amount});
  @override
  List<Object> get props => [beneficiaryId, amount];
}

class SyncPendingTopUpsEvent extends TopUpEvent {
  const SyncPendingTopUpsEvent();
}

class ResetTopUpEvent extends TopUpEvent {
  const ResetTopUpEvent();
}
