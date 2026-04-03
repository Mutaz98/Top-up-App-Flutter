import 'package:equatable/equatable.dart';

abstract class BeneficiariesEvent extends Equatable {
  const BeneficiariesEvent();
  @override
  List<Object?> get props => [];
}

class LoadBeneficiaries extends BeneficiariesEvent {
  const LoadBeneficiaries();
}

class AddBeneficiaryEvent extends BeneficiariesEvent {
  final String nickname;
  final String phoneNumber;
  const AddBeneficiaryEvent({required this.nickname, required this.phoneNumber});
  @override
  List<Object> get props => [nickname, phoneNumber];
}

class DeleteBeneficiaryEvent extends BeneficiariesEvent {
  final String id;
  const DeleteBeneficiaryEvent(this.id);
  @override
  List<Object> get props => [id];
}
