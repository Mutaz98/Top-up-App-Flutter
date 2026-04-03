import 'package:equatable/equatable.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';

abstract class BeneficiariesState extends Equatable {
  const BeneficiariesState();
  @override
  List<Object?> get props => [];
}

class BeneficiariesInitial extends BeneficiariesState {
  const BeneficiariesInitial();
}

class BeneficiariesLoading extends BeneficiariesState {
  const BeneficiariesLoading();
}

class BeneficiariesLoaded extends BeneficiariesState {
  final List<Beneficiary> beneficiaries;
  const BeneficiariesLoaded(this.beneficiaries);
  @override
  List<Object> get props => [beneficiaries];
}

class BeneficiaryOperationInProgress extends BeneficiariesState {
  final List<Beneficiary> beneficiaries;
  const BeneficiaryOperationInProgress(this.beneficiaries);
  @override
  List<Object> get props => [beneficiaries];
}

class BeneficiariesError extends BeneficiariesState {
  final String message;
  final List<Beneficiary> beneficiaries;
  const BeneficiariesError(this.message, {this.beneficiaries = const []});
  @override
  List<Object> get props => [message, beneficiaries];
}
