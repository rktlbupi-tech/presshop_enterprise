import 'package:flutter/foundation.dart';

enum UploadStatus { idle, uploading, success, failed }

class UploadProgressNotifier extends ChangeNotifier {
  UploadProgressNotifier._();
  static final UploadProgressNotifier instance = UploadProgressNotifier._();

  UploadStatus _status = UploadStatus.idle;
  double _progress = 0.0;
  String _title = '';
  String _taskId = '';
  Future<bool> Function()? _onRetry;

  UploadStatus get status => _status;
  double get progress => _progress;
  String get title => _title;
  bool get isUploading => _status == UploadStatus.uploading;

  void startUpload({
    required String taskId,
    required String title,
    Future<bool> Function()? onRetry,
  }) {
    _taskId = taskId;
    _title = title;
    _status = UploadStatus.uploading;
    _progress = 0.0;
    _onRetry = onRetry;
    notifyListeners();
  }

  void updateProgress(double fraction) {
    _progress = fraction.clamp(0.0, 1.0);
    notifyListeners();
  }

  void completeUpload() {
    _status = UploadStatus.success;
    _progress = 1.0;
    notifyListeners();
  }

  void failUpload() {
    _status = UploadStatus.failed;
    notifyListeners();
  }

  Future<void> retry() async {
    if (_onRetry != null) {
      startUpload(taskId: _taskId, title: _title, onRetry: _onRetry);
      await _onRetry!();
    }
  }

  void reset() {
    _status = UploadStatus.idle;
    _progress = 0.0;
    _title = '';
    _taskId = '';
    _onRetry = null;
    notifyListeners();
  }
}
