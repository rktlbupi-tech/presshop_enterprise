import '../../domain/entities/document_entity.dart';

class DocumentModel {
  final String id;
  final String name;
  final String type;
  final String? fileUrl;
  final String? size;
  final DateTime? uploadedAt;
  final String category;

  DocumentModel({
    required this.id,
    required this.name,
    required this.type,
    this.fileUrl,
    this.size,
    this.uploadedAt,
    required this.category,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> j) => DocumentModel(
        id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        type: j['type']?.toString() ?? 'FILE',
        fileUrl: j['fileUrl']?.toString() ?? j['url']?.toString(),
        size: j['size']?.toString(),
        uploadedAt: j['uploadedAt'] != null ? DateTime.tryParse(j['uploadedAt'].toString()) : null,
        category: j['category']?.toString() ?? 'general',
      );

  DocumentEntity toEntity() => DocumentEntity(
        id: id, name: name, type: type, fileUrl: fileUrl,
        size: size, uploadedAt: uploadedAt, category: category,
      );
}
