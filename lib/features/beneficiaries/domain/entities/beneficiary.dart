import 'package:equatable/equatable.dart';

class Beneficiary extends Equatable {
  final String id;
  final String nickname;
  final String phoneNumber;
  final double monthlyTopUpTotal;

  const Beneficiary({
    required this.id,
    required this.nickname,
    required this.phoneNumber,
    required this.monthlyTopUpTotal,
  });

  Beneficiary copyWith({
    String? id,
    String? nickname,
    String? phoneNumber,
    double? monthlyTopUpTotal,
  }) {
    return Beneficiary(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      monthlyTopUpTotal: monthlyTopUpTotal ?? this.monthlyTopUpTotal,
    );
  }

  @override
  List<Object> get props => [id, nickname, phoneNumber, monthlyTopUpTotal];
}
