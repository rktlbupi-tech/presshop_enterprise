import '../../../../core/network/api_client.dart';

class SettingsRemoteDatasource {
  final ApiClient _client;
  SettingsRemoteDatasource(this._client);

  Future<bool> deleteAccount(Map<String, String> reason) async {
    final res = await _client.post('hopper/verifyAndDeleteAccount', data: reason);
    return res.data['success'] == true || res.data['code'] == 200;
  }

  Future<bool> contactUs(Map<String, String> data) async {
    final res = await _client.post('hopper/Addcontact_us', data: data);
    return res.data['success'] == true || res.data['code'] == 200;
  }

  Future<String?> fetchAdminDetails() async {
    final res = await _client.get('hopper/adminDetails');
    return res.data['data']?.toString();
  }

  Future<String?> fetchLegalTerms(String type) async {
    final res = await _client.get('hopper/legalTerms', queryParameters: {'type': type});
    return res.data['data']?.toString();
  }

  Future<bool> changePassword(Map<String, String> data) async {
    final res = await _client.post('auth/changePassword', data: data);
    return res.data['success'] == true || res.data['code'] == 200;
  }
}
