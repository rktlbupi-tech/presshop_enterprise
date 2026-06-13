import '../../../../core/errors/failures.dart';
import '../entities/earning_entity.dart';

abstract class EarningsRepository {
  Future<(List<EarningEntity>, Failure?)> fetchEarnings();
  Future<(double, Failure?)> fetchYtd();
}
