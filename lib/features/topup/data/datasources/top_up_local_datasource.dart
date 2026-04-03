import 'package:hive_flutter/hive_flutter.dart';
import 'package:topup/core/cache/hive_boxes.dart';
import 'package:topup/core/errors/exceptions.dart';
import 'package:topup/features/topup/data/models/pending_top_up_hive_model.dart';

abstract class TopUpLocalDataSource {
  List<PendingTopUpHiveModel> getPendingTopUps();
  Future<void> enqueuePendingTopUp(PendingTopUpHiveModel pending);
  Future<void> clearPendingTopUps();
}

class TopUpLocalDataSourceImpl implements TopUpLocalDataSource {
  Box<PendingTopUpHiveModel> get _box =>
      Hive.box<PendingTopUpHiveModel>(HiveBoxes.pendingTopUps);

  @override
  List<PendingTopUpHiveModel> getPendingTopUps() {
    try {
      return _box.values.toList();
    } catch (e) {
      throw CacheException('Failed to read pending top-ups: $e');
    }
  }

  @override
  Future<void> enqueuePendingTopUp(PendingTopUpHiveModel pending) async {
    try {
      await _box.add(pending);
    } catch (e) {
      throw CacheException('Failed to queue pending top-up: $e');
    }
  }

  @override
  Future<void> clearPendingTopUps() async {
    try {
      await _box.clear();
    } catch (e) {
      throw CacheException('Failed to clear pending top-ups: $e');
    }
  }
}
