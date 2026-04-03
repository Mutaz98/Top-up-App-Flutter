import 'package:hive_flutter/hive_flutter.dart';
import 'package:topup/core/constants/app_constants.dart';
part 'pending_top_up_hive_model.g.dart';

@HiveType(typeId: AppConstants.pendingTopUpHiveTypeId)
class PendingTopUpHiveModel extends HiveObject {
  @HiveField(0)
  final String beneficiaryId;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String timestamp;

  PendingTopUpHiveModel({
    required this.beneficiaryId,
    required this.amount,
    required this.timestamp,
  });
}
