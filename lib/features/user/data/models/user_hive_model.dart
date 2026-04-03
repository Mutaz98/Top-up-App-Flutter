import 'package:hive_flutter/hive_flutter.dart';
import 'package:topup/core/constants/app_constants.dart';
import 'package:topup/features/user/data/models/user_model.dart';

part 'user_hive_model.g.dart';

@HiveType(typeId: AppConstants.userHiveTypeId)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double balance;

  @HiveField(3)
  final bool isVerified;

  @HiveField(4)
  final double monthlyTopUpTotal;

  UserHiveModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.isVerified,
    required this.monthlyTopUpTotal,
  });

  UserModel toEntity() => UserModel(
        id: id,
        name: name,
        balance: balance,
        isVerified: isVerified,
        monthlyTopUpTotal: monthlyTopUpTotal,
      );
}
