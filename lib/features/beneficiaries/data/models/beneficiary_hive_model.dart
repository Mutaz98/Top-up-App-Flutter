import 'package:hive_flutter/hive_flutter.dart';
import 'package:topup/core/constants/app_constants.dart';
import 'package:topup/features/beneficiaries/domain/entities/beneficiary.dart';

part 'beneficiary_hive_model.g.dart';

@HiveType(typeId: AppConstants.beneficiaryHiveTypeId)
class BeneficiaryHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nickname;

  @HiveField(2)
  final String phoneNumber;

  @HiveField(3)
  final double monthlyTopUpTotal;

  BeneficiaryHiveModel({
    required this.id,
    required this.nickname,
    required this.phoneNumber,
    required this.monthlyTopUpTotal,
  });

  Beneficiary toEntity() => Beneficiary(
        id: id,
        nickname: nickname,
        phoneNumber: phoneNumber,
        monthlyTopUpTotal: monthlyTopUpTotal,
      );
}
