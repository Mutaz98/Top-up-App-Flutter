import 'package:equatable/equatable.dart';

class TopUpTransaction extends Equatable {
  final String transactionId;
  final String beneficiaryId;
  final double amount;
  final double fee;
  final DateTime timestamp;

  const TopUpTransaction({
    required this.transactionId,
    required this.beneficiaryId,
    required this.amount,
    required this.fee,
    required this.timestamp,
  });

  double get total => amount + fee;

  @override
  List<Object> get props =>
      [transactionId, beneficiaryId, amount, fee, timestamp];
}
