import 'package:topup/core/errors/exceptions.dart';
import 'package:topup/core/network/http_client.dart';
import 'package:topup/features/user/data/models/user_model.dart';
import 'package:topup/core/network/api_endpoints.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUser();
  Future<UserModel> updateUser(UserModel user);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final HttpClient client;

  const UserRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> getUser() async {
    try {
      final response = await client.get(ApiEndpoints.user);
      return UserModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to fetch user: $e');
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final response = await client.post(ApiEndpoints.user, body: {
        'balance': user.balance,
        'monthly_top_up_total': user.monthlyTopUpTotal,
      });
      return UserModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to update user: $e');
    }
  }
}
