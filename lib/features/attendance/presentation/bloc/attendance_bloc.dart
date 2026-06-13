import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';

// Events
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override List<Object?> get props => [];
}
class FetchAttendanceLog extends AttendanceEvent { const FetchAttendanceLog(); }
class CheckInRequested extends AttendanceEvent {
  final double lat, lng;
  const CheckInRequested(this.lat, this.lng);
  @override List<Object?> get props => [lat, lng];
}
class CheckOutRequested extends AttendanceEvent {
  final double lat, lng;
  const CheckOutRequested(this.lat, this.lng);
  @override List<Object?> get props => [lat, lng];
}

// States
abstract class AttendanceState extends Equatable {
  const AttendanceState();
  @override List<Object?> get props => [];
}
class AttendanceInitial extends AttendanceState { const AttendanceInitial(); }
class AttendanceLoading extends AttendanceState { const AttendanceLoading(); }
class AttendanceLoaded extends AttendanceState {
  final List<AttendanceLogEntity> logs;
  final AttendanceSummaryEntity? summary;
  final bool isCheckedIn;
  const AttendanceLoaded({required this.logs, this.summary, this.isCheckedIn = false});
  @override List<Object?> get props => [logs, summary, isCheckedIn];
}
class AttendanceActionSuccess extends AttendanceState {
  final String message;
  final bool isCheckedIn;
  const AttendanceActionSuccess(this.message, {required this.isCheckedIn});
  @override List<Object?> get props => [message, isCheckedIn];
}
class AttendanceError extends AttendanceState {
  final String message;
  const AttendanceError(this.message);
  @override List<Object?> get props => [message];
}

// BLoC
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository _repo;
  bool _isCheckedIn = false;

  AttendanceBloc(this._repo) : super(const AttendanceInitial()) {
    on<FetchAttendanceLog>(_onFetch);
    on<CheckInRequested>(_onCheckIn);
    on<CheckOutRequested>(_onCheckOut);
  }

  Future<void> _onFetch(FetchAttendanceLog e, Emitter<AttendanceState> emit) async {
    emit(const AttendanceLoading());
    final (logs, failure) = await _repo.fetchLog();
    if (failure != null) { emit(AttendanceError(failure.message)); return; }
    final (summary, _) = await _repo.fetchSummary();
    emit(AttendanceLoaded(logs: logs, summary: summary, isCheckedIn: _isCheckedIn));
  }

  Future<void> _onCheckIn(CheckInRequested e, Emitter<AttendanceState> emit) async {
    emit(const AttendanceLoading());
    final (success, failure) = await _repo.checkIn(e.lat, e.lng);
    if (failure != null) { emit(AttendanceError(failure.message)); return; }
    if (success) {
      _isCheckedIn = true;
      emit(AttendanceActionSuccess('Checked in successfully!', isCheckedIn: true));
    }
  }

  Future<void> _onCheckOut(CheckOutRequested e, Emitter<AttendanceState> emit) async {
    emit(const AttendanceLoading());
    final (success, failure) = await _repo.checkOut(e.lat, e.lng);
    if (failure != null) { emit(AttendanceError(failure.message)); return; }
    if (success) {
      _isCheckedIn = false;
      emit(AttendanceActionSuccess('Checked out successfully!', isCheckedIn: false));
    }
  }
}
