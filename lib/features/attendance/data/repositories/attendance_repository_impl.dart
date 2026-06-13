import '../../../../core/errors/failures.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDatasource _ds;
  AttendanceRepositoryImpl(this._ds);

  @override
  Future<(bool, Failure?)> checkIn(double lat, double lng) async {
    try { return (await _ds.checkIn(lat, lng), null); }
    on Failure catch (f) { return (false, f); }
    catch (e) { return (false, UnknownFailure(e.toString())); }
  }

  @override
  Future<(bool, Failure?)> checkOut(double lat, double lng) async {
    try { return (await _ds.checkOut(lat, lng), null); }
    on Failure catch (f) { return (false, f); }
    catch (e) { return (false, UnknownFailure(e.toString())); }
  }

  @override
  Future<(List<AttendanceLogEntity>, Failure?)> fetchLog() async {
    try {
      final models = await _ds.fetchLog();
      return (models.map((m) => m.toEntity()).toList(), null);
    } on Failure catch (f) { return (<AttendanceLogEntity>[], f); }
    catch (e) { return (<AttendanceLogEntity>[], UnknownFailure(e.toString())); }
  }

  @override
  Future<(AttendanceSummaryEntity?, Failure?)> fetchSummary() async {
    try { return ((await _ds.fetchSummary()).toEntity(), null); }
    on Failure catch (f) { return (null, f); }
    catch (e) { return (null, UnknownFailure(e.toString())); }
  }
}
