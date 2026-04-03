import 'package:topup/features/topup/domain/entities/top_up_transaction.dart';

class TopUpTransactionModel {
  final String transactionId;
  final String beneficiaryId;
  final double amount;
  final double fee;
  final DateTime timestamp;

  const TopUpTransactionModel({
    required this.transactionId,
    required this.beneficiaryId,
    required this.amount,
    required this.fee,
    required this.timestamp,
  });

  factory TopUpTransactionModel.fromJson(Map<String, dynamic> json) =>
      TopUpTransactionModel(
        transactionId: json['transaction_id'] as String,
        beneficiaryId: json['beneficiary_id'] as String,
        amount: (json['amount'] as num).toDouble(),
        fee: (json['fee'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  TopUpTransaction toEntity() => TopUpTransaction(
        transactionId: transactionId,
        beneficiaryId: beneficiaryId,
        amount: amount,
        fee: fee,
        timestamp: timestamp,
      );
}
