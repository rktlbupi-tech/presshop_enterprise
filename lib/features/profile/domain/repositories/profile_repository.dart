import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<(ProfileEntity?, Failure?)> fetchProfile();
  Future<(bool, Failure?)> updateProfile(Map<String, dynamic> data);
}
