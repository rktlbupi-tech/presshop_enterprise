import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override List<Object?> get props => [];
}
class FetchProfile extends ProfileEvent { const FetchProfile(); }
class UpdateProfile extends ProfileEvent {
  final Map<String, dynamic> data;
  const UpdateProfile(this.data);
  @override List<Object?> get props => [data];
}

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override List<Object?> get props => [];
}
class ProfileInitial extends ProfileState { const ProfileInitial(); }
class ProfileLoading extends ProfileState { const ProfileLoading(); }
class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  const ProfileLoaded(this.profile);
  @override List<Object?> get props => [profile];
}
class ProfileUpdateSuccess extends ProfileState { const ProfileUpdateSuccess(); }
class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override List<Object?> get props => [message];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repo;
  ProfileBloc(this._repo) : super(const ProfileInitial()) {
    on<FetchProfile>(_onFetch);
    on<UpdateProfile>(_onUpdate);
  }

  Future<void> _onFetch(FetchProfile e, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    final (profile, failure) = await _repo.fetchProfile();
    if (failure != null) { emit(ProfileError(failure.message)); return; }
    emit(ProfileLoaded(profile!));
  }

  Future<void> _onUpdate(UpdateProfile e, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    final (success, failure) = await _repo.updateProfile(e.data);
    if (failure != null) { emit(ProfileError(failure.message)); return; }
    if (success) {
      emit(const ProfileUpdateSuccess());
      add(const FetchProfile());
    }
  }
}
