import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/earning_model.dart';

class EarningsRemoteDatasource {
  final ApiClient _client;
  EarningsRemoteDatasource(this._client);

  Future<List<EarningModel>> fetchEarnings() async {
    final res = await _client.get(ApiEndpoints.earnings);
    final data = res.data['data'] as List<dynamic>? ?? [];
    return data.map((e) => EarningModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<double> fetchYtd() async {
    final res = await _client.get(ApiEndpoints.earnings, queryParameters: {'ytd': true});
    return (res.data['ytd'] as num?)?.toDouble() ?? 0;
  }
}
