import 'package:topup/features/user/data/models/user_hive_model.dart';
import 'package:topup/features/user/domain/entities/user.dart';

class UserModel {
  final String id;
  final String name;
  final double balance;
  final bool isVerified;
  final double monthlyTopUpTotal;

  const UserModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.isVerified,
    required this.monthlyTopUpTotal,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        balance: (json['balance'] as num).toDouble(),
        isVerified: json['is_verified'] as bool,
        monthlyTopUpTotal: (json['monthly_top_up_total'] as num).toDouble(),
      );

  User toEntity() => User(
        id: id,
        name: name,
        balance: balance,
        isVerified: isVerified,
        monthlyTopUpTotal: monthlyTopUpTotal,
      );

  UserHiveModel toHiveModel() => UserHiveModel(
        id: id,
        name: name,
        balance: balance,
        isVerified: isVerified,
        monthlyTopUpTotal: monthlyTopUpTotal,
      );

  static UserModel fromHiveModel(UserHiveModel h) => UserModel(
        id: h.id,
        name: h.name,
        balance: h.balance,
        isVerified: h.isVerified,
        monthlyTopUpTotal: h.monthlyTopUpTotal,
      );
}
