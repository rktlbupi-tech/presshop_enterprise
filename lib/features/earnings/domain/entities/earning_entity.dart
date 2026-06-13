import 'package:equatable/equatable.dart';

class EarningEntity extends Equatable {
  final String id;
  final String month;
  final int year;
  final double netEarnings;
  final double basicSalary;
  final double hra;
  final double da;
  final double specialAllowance;
  final double bonus;
  final double reimbursements;
  final double deductions;
  final DateTime? payDate;
  final String status; // 'paid', 'pending'

  const EarningEntity({
    required this.id,
    required this.month,
    required this.year,
    required this.netEarnings,
    required this.basicSalary,
    required this.hra,
    required this.da,
    required this.specialAllowance,
    required this.bonus,
    required this.reimbursements,
    required this.deductions,
    this.payDate,
    required this.status,
  });

  double get ytd => netEarnings; // server returns YTD separately

  @override
  List<Object?> get props => [id, month, year, netEarnings, status];
}
