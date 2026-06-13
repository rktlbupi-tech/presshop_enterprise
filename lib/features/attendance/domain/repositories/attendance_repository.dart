import '../../../../core/errors/failures.dart';
import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<(bool, Failure?)> checkIn(double lat, double lng);
  Future<(bool, Failure?)> checkOut(double lat, double lng);
  Future<(List<AttendanceLogEntity>, Failure?)> fetchLog();
  Future<(AttendanceSummaryEntity?, Failure?)> fetchSummary();
}
