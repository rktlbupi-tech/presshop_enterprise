import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_config.dart';
import '../data/models/camera_data.dart';

class CameraTaskService {
  late final Dio _dio;

  CameraTaskService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  Future<List<CameraTaskModel>> fetchTodayTasks({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final res = await _dio.get(
        'enterprise/tasks',
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
          'limit': 50,
        },
      );
      final data = res.data['data'];
      if (data is List) {
        return data
            .map((e) => CameraTaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> uploadEvidence({
    required String taskId,
    required List<CameraTaskMediaData> mediaList,
    required double latitude,
    required double longitude,
    required String address,
    String? description,
    void Function(double)? onProgress,
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('taskId', taskId));
      formData.fields.add(MapEntry('latitude', latitude.toString()));
      formData.fields.add(MapEntry('longitude', longitude.toString()));
      formData.fields.add(MapEntry('address', address));
      if (description != null && description.isNotEmpty) {
        formData.fields.add(MapEntry('description', description));
      }

      for (final media in mediaList) {
        if (media.isLocalMedia && !media.mediaPath.startsWith('http')) {
          final file = File(media.mediaPath);
          if (await file.exists()) {
            formData.files.add(MapEntry(
              'media',
              await MultipartFile.fromFile(
                media.mediaPath,
                filename: file.uri.pathSegments.last,
              ),
            ));
          }
        }
      }

      final res = await _dio.post(
        'enterprise/tasks/$taskId/evidence',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) onProgress?.call(sent / total);
        },
      );
      return res.data['success'] == true;
    } catch (_) {
      return false;
    }
  }
}
