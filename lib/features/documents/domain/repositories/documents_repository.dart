import '../../../../core/errors/failures.dart';
import '../entities/document_entity.dart';

abstract class DocumentsRepository {
  Future<(List<DocumentEntity>, Failure?)> fetchDocuments();
}
