import 'package:topup/core/errors/exceptions.dart';
import 'package:topup/core/network/http_client.dart';
import 'package:topup/features/topup/data/models/top_up_transaction_model.dart';
import 'package:topup/core/network/api_endpoints.dart';

abstract class TopUpRemoteDataSource {
  Future<TopUpTransactionModel> executeTopUp({
    required String beneficiaryId,
    required double amount,
    required double fee,
  });
}

class TopUpRemoteDataSourceImpl implements TopUpRemoteDataSource {
  final HttpClient client;

  const TopUpRemoteDataSourceImpl(this.client);

  @override
  Future<TopUpTransactionModel> executeTopUp({
    required String beneficiaryId,
    required double amount,
    required double fee,
  }) async {
    try {
      final response = await client.post(ApiEndpoints.topUp, body: {
        'beneficiary_id': beneficiaryId,
        'amount': amount,
        'fee': fee,
      });
      return TopUpTransactionModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to execute top-up: $e');
    }
  }
}
