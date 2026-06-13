import '../../domain/entities/attendance_entity.dart';

class AttendanceLogModel {
  final String id;
  final DateTime date;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String status;
  final double? workedHours;

  AttendanceLogModel({
    required this.id,
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    this.workedHours,
  });

  factory AttendanceLogModel.fromJson(Map<String, dynamic> j) {
    return AttendanceLogModel(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      date: DateTime.tryParse(j['date']?.toString() ?? '') ?? DateTime.now(),
      checkIn: j['checkIn'] != null ? DateTime.tryParse(j['checkIn'].toString()) : null,
      checkOut: j['checkOut'] != null ? DateTime.tryParse(j['checkOut'].toString()) : null,
      status: j['status']?.toString() ?? 'present',
      workedHours: (j['workedHours'] as num?)?.toDouble(),
    );
  }

  AttendanceLogEntity toEntity() => AttendanceLogEntity(
        id: id,
        date: date,
        checkIn: checkIn,
        checkOut: checkOut,
        status: status,
        workedHours: workedHours,
      );
}

class AttendanceSummaryModel {
  final int present, absent, late, leaves, totalDays;
  AttendanceSummaryModel({
    required this.present,
    required this.absent,
    required this.late,
    required this.leaves,
    required this.totalDays,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> j) =>
      AttendanceSummaryModel(
        present: (j['present'] as num?)?.toInt() ?? 0,
        absent: (j['absent'] as num?)?.toInt() ?? 0,
        late: (j['late'] as num?)?.toInt() ?? 0,
        leaves: (j['leaves'] as num?)?.toInt() ?? 0,
        totalDays: (j['totalDays'] as num?)?.toInt() ?? 0,
      );

  AttendanceSummaryEntity toEntity() => AttendanceSummaryEntity(
        present: present, absent: absent, late: late,
        leaves: leaves, totalDays: totalDays,
      );
}
