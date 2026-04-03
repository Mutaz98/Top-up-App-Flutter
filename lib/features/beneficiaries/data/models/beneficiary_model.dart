import 'package:topup/features/beneficiaries/data/models/beneficiary_hive_model.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';

class BeneficiaryModel {
  final String id;
  final String nickname;
  final String phoneNumber;
  final double monthlyTopUpTotal;

  const BeneficiaryModel({
    required this.id,
    required this.nickname,
    required this.phoneNumber,
    required this.monthlyTopUpTotal,
  });

  factory BeneficiaryModel.fromJson(Map<String, dynamic> json) =>
      BeneficiaryModel(
        id: json['id'] as String,
        nickname: json['nickname'] as String,
        phoneNumber: json['phone_number'] as String,
        monthlyTopUpTotal: (json['monthly_top_up_total'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'phone_number': phoneNumber,
        'monthly_top_up_total': monthlyTopUpTotal,
      };

  Beneficiary toEntity() => Beneficiary(
        id: id,
        nickname: nickname,
        phoneNumber: phoneNumber,
        monthlyTopUpTotal: monthlyTopUpTotal,
      );

  BeneficiaryHiveModel toHiveModel() => BeneficiaryHiveModel(
        id: id,
        nickname: nickname,
        phoneNumber: phoneNumber,
        monthlyTopUpTotal: monthlyTopUpTotal,
      );

  static BeneficiaryModel fromEntity(Beneficiary b) => BeneficiaryModel(
        id: b.id,
        nickname: b.nickname,
        phoneNumber: b.phoneNumber,
        monthlyTopUpTotal: b.monthlyTopUpTotal,
      );

  static BeneficiaryModel fromHiveModel(BeneficiaryHiveModel h) =>
      BeneficiaryModel(
        id: h.id,
        nickname: h.nickname,
        phoneNumber: h.phoneNumber,
        monthlyTopUpTotal: h.monthlyTopUpTotal,
      );
}
