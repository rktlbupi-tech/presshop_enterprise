import 'package:presshop_enterprise/core/network/api_endpoints.dart';

import '../../../../core/network/api_client.dart';

class SettingsRemoteDatasource {
  final ApiClient _client;
  SettingsRemoteDatasource(this._client);

  Future<bool> deleteAccount(Map<String, String> reason) async {
    final res = await _client.post(ApiEndpoints.deleteAccount, data: reason);
    return res.data['success'] == true || res.data['code'] == 200;
  }

  Future<bool> contactUs(Map<String, String> data) async {
    final res = await _client.post(ApiEndpoints.contactUs, data: data);
    return res.data['success'] == true || res.data['code'] == 200;
  }

  Future<String?> fetchAdminDetails() async {
    final res = await _client.get('hopper/adminDetails');
    return res.data['data']?.toString();
  }

  Future<String?> fetchLegalTerms(String type) async {
    final res = await _client.get(
      ApiEndpoints.getGeneralMgmtApp,
      queryParameters: {'type': type, 'role': 'enterprise'},
    );
    if (res.data['status'] != null &&
        res.data['status']['description'] != null) {
      return res.data['status']['description']?.toString();
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchCategories(String type) async {
    final res = await _client.get(
      ApiEndpoints.getCategory,
      queryParameters: {'type': type, 'role': 'enterprise'},
    );
    if (res.data['categories'] != null) {
      return List<Map<String, dynamic>>.from(res.data['categories']);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchFaqs(
    String type,
    String category,
    int offset,
  ) async {
    final res = await _client.get(
      ApiEndpoints.getGeneralMgmtApp,
      queryParameters: {
        'type': type,
        'category': category,
        'offset': offset,
        'limit': 10,
        'role': 'enterprise',
      },
    );
    if (res.data['status'] != null) {
      return List<Map<String, dynamic>>.from(res.data['status']);
    }
    return [];
  }

  Future<bool> changePassword(Map<String, String> data) async {
    final res = await _client.post(ApiEndpoints.changePassword, data: data);
    return res.data['success'] == true || res.data['code'] == 200;
  }
}
