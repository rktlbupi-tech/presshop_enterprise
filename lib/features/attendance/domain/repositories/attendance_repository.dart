import 'dart:io';
import '../../../../core/errors/failures.dart';
import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<(bool, Failure?)> checkIn(double lat, double lng);
  Future<(bool, Failure?)> checkOut(double lat, double lng);
  Future<(List<AttendanceLogEntity>, Failure?)> fetchLog();
  Future<(AttendanceSummaryEntity?, Failure?)> fetchSummary();

  /// Uploads the uniform selfie, returning its hosted URL (or a [Failure]).
  Future<(String?, Failure?)> uploadSelfie(File file);

  /// Records an attendance punch (clock_in / break_start / break_end /
  /// clock_out) for the logged-in worker.
  Future<(bool, Failure?)> punch({
    required String kind,
    double? lat,
    double? lng,
    double? accuracyMeters,
    String? photoUrl,
  });
}
