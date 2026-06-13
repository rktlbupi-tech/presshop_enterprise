import '../../domain/entities/earning_entity.dart';

class EarningModel {
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
  final String status;

  EarningModel({
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

  factory EarningModel.fromJson(Map<String, dynamic> j) {
    final comp = j['salaryComponents'] as Map<String, dynamic>? ?? {};
    return EarningModel(
      id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
      month: j['month']?.toString() ?? '',
      year: (j['year'] as num?)?.toInt() ?? DateTime.now().year,
      netEarnings: (j['netEarnings'] as num?)?.toDouble() ?? 0,
      basicSalary: (comp['basicSalary'] as num?)?.toDouble() ?? 0,
      hra: (comp['hra'] as num?)?.toDouble() ?? 0,
      da: (comp['da'] as num?)?.toDouble() ?? 0,
      specialAllowance: (comp['specialAllowance'] as num?)?.toDouble() ?? 0,
      bonus: (j['bonus'] as num?)?.toDouble() ?? 0,
      reimbursements: (j['reimbursements'] as num?)?.toDouble() ?? 0,
      deductions: (j['deductions'] as num?)?.toDouble() ?? 0,
      payDate: j['payDate'] != null ? DateTime.tryParse(j['payDate'].toString()) : null,
      status: j['status']?.toString() ?? 'pending',
    );
  }

  EarningEntity toEntity() => EarningEntity(
        id: id, month: month, year: year, netEarnings: netEarnings,
        basicSalary: basicSalary, hra: hra, da: da,
        specialAllowance: specialAllowance, bonus: bonus,
        reimbursements: reimbursements, deductions: deductions,
        payDate: payDate, status: status,
      );
}
