import 'package:equatable/equatable.dart';

class AttendanceLogEntity extends Equatable {
  final String id;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String status; // 'present', 'absent', 'late', 'half-day'
  final double? workedHours;

  const AttendanceLogEntity({
    required this.id,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.workedHours,
  });

  @override
  List<Object?> get props => [id, date, status];
}

class AttendanceSummaryEntity extends Equatable {
  final int present;
  final int absent;
  final int late;
  final int leaves;
  final int totalDays;

  const AttendanceSummaryEntity({
    required this.present,
    required this.absent,
    required this.late,
    required this.leaves,
    required this.totalDays,
  });

  @override
  List<Object?> get props => [present, absent, late, leaves, totalDays];
}
