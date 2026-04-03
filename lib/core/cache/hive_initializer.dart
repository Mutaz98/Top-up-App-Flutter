import 'package:hive_flutter/hive_flutter.dart';
import 'package:topup/core/cache/hive_boxes.dart';
import 'package:topup/features/beneficiaries/data/models/beneficiary_hive_model.dart';
import 'package:topup/features/topup/data/models/pending_top_up_hive_model.dart';
import 'package:topup/features/user/data/models/user_hive_model.dart';

class HiveInitializer {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(UserHiveModelAdapter());
    Hive.registerAdapter(BeneficiaryHiveModelAdapter());
    Hive.registerAdapter(PendingTopUpHiveModelAdapter());

    // Open boxes
    await Hive.openBox<UserHiveModel>(HiveBoxes.user);
    await Hive.openBox<BeneficiaryHiveModel>(HiveBoxes.beneficiary);
    await Hive.openBox<PendingTopUpHiveModel>(HiveBoxes.pendingTopUps);
  }
}
