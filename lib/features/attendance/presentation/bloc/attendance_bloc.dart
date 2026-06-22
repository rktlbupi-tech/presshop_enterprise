// ignore_for_file: unused_field

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';

// Events
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object?> get props => [];
}

class FetchAttendanceLog extends AttendanceEvent {
  const FetchAttendanceLog();
}

class CheckInRequested extends AttendanceEvent {
  final double lat, lng;
  const CheckInRequested(this.lat, this.lng);
  @override
  List<Object?> get props => [lat, lng];
}

class CheckOutRequested extends AttendanceEvent {
  final double lat, lng;
  const CheckOutRequested(this.lat, this.lng);
  @override
  List<Object?> get props => [lat, lng];
}

// States
abstract class AttendanceState extends Equatable {
  const AttendanceState();
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceLogEntity> logs;
  final AttendanceSummaryEntity? summary;
  final bool isCheckedIn;
  const AttendanceLoaded({
    required this.logs,
    this.summary,
    this.isCheckedIn = false,
  });
  @override
  List<Object?> get props => [logs, summary, isCheckedIn];
}

class AttendanceActionSuccess extends AttendanceState {
  final String message;
  final bool isCheckedIn;
  const AttendanceActionSuccess(this.message, {required this.isCheckedIn});
  @override
  List<Object?> get props => [message, isCheckedIn];
}

class AttendanceError extends AttendanceState {
  final String message;
  const AttendanceError(this.message);
  @override
  List<Object?> get props => [message];
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

  Future<void> _onFetch(
    FetchAttendanceLog e,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    final List<AttendanceLogEntity> dummyLogs = [];

    for (int i = 0; i < 15; i++) {
      final logDate = now.subtract(Duration(days: i));
      if (logDate.weekday == DateTime.sunday) continue;

      String status = 'present';
      double workedHours = 8.5;
      DateTime checkInTime = DateTime(
        logDate.year,
        logDate.month,
        logDate.day,
        9,
        15,
      );
      DateTime? checkOutTime = DateTime(
        logDate.year,
        logDate.month,
        logDate.day,
        17,
        45,
      );

      if (i == 2) {
        status = 'late';
        workedHours = 7.0;
        checkInTime = DateTime(
          logDate.year,
          logDate.month,
          logDate.day,
          10,
          45,
        );
      } else if (i == 5) {
        status = 'absent';
        workedHours = 0.0;
        checkInTime = DateTime(logDate.year, logDate.month, logDate.day, 0, 0);
        checkOutTime = null;
      } else if (i == 9) {
        status = 'late';
        workedHours = 7.5;
        checkInTime = DateTime(
          logDate.year,
          logDate.month,
          logDate.day,
          10,
          15,
        );
      }

      dummyLogs.add(
        AttendanceLogEntity(
          id: 'dummy_$i',
          date: logDate,
          checkIn: status == 'absent' ? null : checkInTime,
          checkOut: checkOutTime,
          status: status,
          workedHours: workedHours,
        ),
      );
    }

    const dummySummary = AttendanceSummaryEntity(
      present: 13,
      absent: 1,
      late: 2,
      leaves: 0,
      totalDays: 16,
    );

    emit(
      AttendanceLoaded(
        logs: dummyLogs,
        summary: dummySummary,
        isCheckedIn: _isCheckedIn,
      ),
    );
  }

  Future<void> _onCheckIn(
    CheckInRequested e,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    _isCheckedIn = true;
    emit(
      const AttendanceActionSuccess(
        'Checked in successfully!',
        isCheckedIn: true,
      ),
    );
  }

  Future<void> _onCheckOut(
    CheckOutRequested e,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    _isCheckedIn = false;
    emit(
      const AttendanceActionSuccess(
        'Checked out successfully!',
        isCheckedIn: false,
      ),
    );
  }
}
