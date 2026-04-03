import 'package:topup/core/network/http_client.dart';
import 'package:topup/core/network/api_endpoints.dart';

/// Mock HTTP client
class MockHttpClient implements HttpClient {
  static const _delay = Duration(milliseconds: 400);

  // Mutable in-memory state so top-ups / add-beneficiary mutate it
  final Map<String, dynamic> _user = {
    'id': 'user_001',
    'name': 'Ahmed Al Rashid',
    'balance': 2500.00,
    'is_verified': false,
    'monthly_top_up_total': 0.0,
  };

  final List<Map<String, dynamic>> _beneficiaries = [
    {
      'id': 'ben_001',
      'nickname': 'Mom',
      'phone_number': '+971501234567',
      'monthly_top_up_total': 150.0,
    },
    {
      'id': 'ben_002',
      'nickname': 'Office Phone',
      'phone_number': '+971509876543',
      'monthly_top_up_total': 0.0,
    },
  ];

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    await Future.delayed(_delay);
    switch (endpoint) {
      case ApiEndpoints.user:
        return Map<String, dynamic>.from(_user);
      case ApiEndpoints.beneficiaries:
        return {
          'beneficiaries': List<Map<String, dynamic>>.from(_beneficiaries)
        };
      default:
        throw Exception('Unknown endpoint: $endpoint');
    }
  }

  @override
  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    await Future.delayed(_delay);
    switch (endpoint) {
      case ApiEndpoints.beneficiaries:
        final newBen = Map<String, dynamic>.from(body);
        _beneficiaries.add(newBen);
        return newBen;

      case ApiEndpoints.deleteBeneficiary:
        _beneficiaries.removeWhere((b) => b['id'] == body['id']);
        return {'success': true};

      case ApiEndpoints.topUp:
        final amount = (body['amount'] as num).toDouble();
        final fee = (body['fee'] as num).toDouble();
        final bId = body['beneficiary_id'] as String;
        _user['balance'] = (_user['balance'] as double) - amount - fee;
        _user['monthly_top_up_total'] =
            (_user['monthly_top_up_total'] as double) + amount;
        final ben = _beneficiaries.firstWhere((b) => b['id'] == bId);
        ben['monthly_top_up_total'] =
            (ben['monthly_top_up_total'] as double) + amount;
        return {
          'transaction_id': 'txn_${DateTime.now().millisecondsSinceEpoch}',
          'amount': amount,
          'fee': fee,
          'beneficiary_id': bId,
          'timestamp': DateTime.now().toIso8601String(),
        };

      default:
        throw Exception('Unknown endpoint: $endpoint');
    }
  }
}
