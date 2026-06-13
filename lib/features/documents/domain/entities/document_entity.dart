import 'package:equatable/equatable.dart';

class DocumentEntity extends Equatable {
  final String id;
  final String name;
  final String type; // 'PDF', 'PNG', 'DOCX', etc.
  final String? fileUrl;
  final String? size;
  final DateTime? uploadedAt;
  final String category; // 'payslip', 'contract', 'id', 'review', etc.

  const DocumentEntity({
    required this.id,
    required this.name,
    required this.type,
    this.fileUrl,
    this.size,
    this.uploadedAt,
    required this.category,
  });

  @override
  List<Object?> get props => [id, name, type, category];
}
