import 'package:topup/core/errors/exceptions.dart';
import 'package:topup/core/network/http_client.dart';
import 'package:topup/features/beneficiaries/data/models/beneficiary_model.dart';
import 'package:topup/core/network/api_endpoints.dart';

abstract class BeneficiaryRemoteDataSource {
  Future<List<BeneficiaryModel>> getBeneficiaries();
  Future<BeneficiaryModel> addBeneficiary(BeneficiaryModel beneficiary);
  Future<void> deleteBeneficiary(String id);
}

class BeneficiaryRemoteDataSourceImpl implements BeneficiaryRemoteDataSource {
  final HttpClient client;

  const BeneficiaryRemoteDataSourceImpl(this.client);

  @override
  Future<List<BeneficiaryModel>> getBeneficiaries() async {
    try {
      final response = await client.get(ApiEndpoints.beneficiaries);
      final list = response['beneficiaries'] as List<dynamic>;
      return list
          .map((e) => BeneficiaryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch beneficiaries: $e');
    }
  }

  @override
  Future<BeneficiaryModel> addBeneficiary(BeneficiaryModel beneficiary) async {
    try {
      final response =
          await client.post(ApiEndpoints.beneficiaries, body: beneficiary.toJson());
      return BeneficiaryModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to add beneficiary: $e');
    }
  }

  @override
  Future<void> deleteBeneficiary(String id) async {
    try {
      await client.post(ApiEndpoints.deleteBeneficiary, body: {'id': id});
    } catch (e) {
      throw ServerException('Failed to delete beneficiary: $e');
    }
  }
}
