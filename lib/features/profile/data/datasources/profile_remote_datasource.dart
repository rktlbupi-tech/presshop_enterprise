import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/profile_model.dart';

class ProfileRemoteDatasource {
  final ApiClient _client;
  ProfileRemoteDatasource(this._client);

  Future<ProfileModel> fetchProfile() async {
    final res = await _client.get(ApiEndpoints.getProfile);
    final data = res.data['user'] ?? res.data['data'] ?? res.data;
    return ProfileModel.fromJson(data as Map<String, dynamic>);
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final res = await _client.patch(ApiEndpoints.updateProfile, data: data);
    return res.data['success'] == true || res.data['status'] == 'success';
  }
}
