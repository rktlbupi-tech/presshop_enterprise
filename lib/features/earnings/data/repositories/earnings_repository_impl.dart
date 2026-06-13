import '../../../../core/errors/failures.dart';
import '../../domain/entities/earning_entity.dart';
import '../../domain/repositories/earnings_repository.dart';
import '../datasources/earnings_remote_datasource.dart';

class EarningsRepositoryImpl implements EarningsRepository {
  final EarningsRemoteDatasource _ds;
  EarningsRepositoryImpl(this._ds);

  @override
  Future<(List<EarningEntity>, Failure?)> fetchEarnings() async {
    try {
      final models = await _ds.fetchEarnings();
      return (models.map((m) => m.toEntity()).toList(), null);
    } on Failure catch (f) { return (<EarningEntity>[], f); }
    catch (e) { return (<EarningEntity>[], UnknownFailure(e.toString())); }
  }

  @override
  Future<(double, Failure?)> fetchYtd() async {
    try { return (await _ds.fetchYtd(), null); }
    on Failure catch (f) { return (0.0, f); }
    catch (e) { return (0.0, UnknownFailure(e.toString())); }
  }
}
