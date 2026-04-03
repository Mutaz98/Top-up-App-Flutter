import 'package:hive_flutter/hive_flutter.dart';
import 'package:topup/core/cache/hive_boxes.dart';
import 'package:topup/core/errors/exceptions.dart';
import 'package:topup/features/user/data/models/user_hive_model.dart';
import 'package:topup/features/user/data/models/user_model.dart';

abstract class UserLocalDataSource {
  UserModel? getCachedUser();
  Future<void> cacheUser(UserHiveModel user);
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  Box<UserHiveModel> get _box => Hive.box<UserHiveModel>(HiveBoxes.user);

  @override
  UserModel? getCachedUser() {
    try {
      final hiveModel = _box.get('current_user');
      if (hiveModel == null) return null;
      return UserModel.fromHiveModel(hiveModel);
    } catch (e) {
      throw CacheException('Failed to read cached user: $e');
    }
  }

  @override
  Future<void> cacheUser(UserHiveModel user) async {
    try {
      await _box.put('current_user', user);
    } catch (e) {
      throw CacheException('Failed to cache user: $e');
    }
  }
}
