import '../../../../core/errors/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource _ds;
  ProfileRepositoryImpl(this._ds);

  @override
  Future<(ProfileEntity?, Failure?)> fetchProfile() async {
    try { return ((await _ds.fetchProfile()).toEntity(), null); }
    on Failure catch (f) { return (null, f); }
    catch (e) { return (null, UnknownFailure(e.toString())); }
  }

  @override
  Future<(bool, Failure?)> updateProfile(Map<String, dynamic> data) async {
    try { return (await _ds.updateProfile(data), null); }
    on Failure catch (f) { return (false, f); }
    catch (e) { return (false, UnknownFailure(e.toString())); }
  }
}
