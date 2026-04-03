import 'package:hive_flutter/hive_flutter.dart';
import 'package:topup/core/cache/hive_boxes.dart';
import 'package:topup/core/errors/exceptions.dart';
import 'package:topup/features/beneficiaries/data/models/beneficiary_hive_model.dart';
import 'package:topup/features/beneficiaries/data/models/beneficiary_model.dart';

abstract class BeneficiaryLocalDataSource {
  List<BeneficiaryModel> getCachedBeneficiaries();
  Future<void> cacheBeneficiaries(List<BeneficiaryHiveModel> beneficiaries);
  Future<void> addBeneficiary(BeneficiaryHiveModel beneficiary);
  Future<void> deleteBeneficiary(String id);
}

class BeneficiaryLocalDataSourceImpl implements BeneficiaryLocalDataSource {
  Box<BeneficiaryHiveModel> get _box =>
      Hive.box<BeneficiaryHiveModel>(HiveBoxes.beneficiary);

  @override
  List<BeneficiaryModel> getCachedBeneficiaries() {
    try {
      return _box.values.map(BeneficiaryModel.fromHiveModel).toList();
    } catch (e) {
      throw CacheException('Failed to read cached beneficiaries: $e');
    }
  }

  @override
  Future<void> cacheBeneficiaries(
      List<BeneficiaryHiveModel> beneficiaries) async {
    try {
      await _box.clear();
      final map = {for (final b in beneficiaries) b.id: b};
      await _box.putAll(map);
    } catch (e) {
      throw CacheException('Failed to cache beneficiaries: $e');
    }
  }

  @override
  Future<void> addBeneficiary(BeneficiaryHiveModel beneficiary) async {
    try {
      await _box.put(beneficiary.id, beneficiary);
    } catch (e) {
      throw CacheException('Failed to add beneficiary to cache: $e');
    }
  }

  @override
  Future<void> deleteBeneficiary(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete beneficiary from cache: $e');
    }
  }
}
