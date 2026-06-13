import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/attendance_model.dart';

class AttendanceRemoteDatasource {
  final ApiClient _client;
  AttendanceRemoteDatasource(this._client);

  Future<bool> checkIn(double lat, double lng) async {
    final res = await _client.post(ApiEndpoints.checkIn,
        data: {'latitude': lat, 'longitude': lng});
    return res.data['success'] == true;
  }

  Future<bool> checkOut(double lat, double lng) async {
    final res = await _client.post(ApiEndpoints.checkOut,
        data: {'latitude': lat, 'longitude': lng});
    return res.data['success'] == true;
  }

  Future<List<AttendanceLogModel>> fetchLog() async {
    final res = await _client.get(ApiEndpoints.attendanceLog);
    final data = res.data['data'] as List<dynamic>? ?? [];
    return data.map((e) => AttendanceLogModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AttendanceSummaryModel> fetchSummary() async {
    final res = await _client.get(ApiEndpoints.attendanceLog, queryParameters: {'summary': true});
    return AttendanceSummaryModel.fromJson(res.data['summary'] as Map<String, dynamic>? ?? {});
  }
}
