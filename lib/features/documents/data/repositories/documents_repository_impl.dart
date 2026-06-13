import '../../../../core/errors/failures.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/documents_repository.dart';
import '../datasources/documents_remote_datasource.dart';

class DocumentsRepositoryImpl implements DocumentsRepository {
  final DocumentsRemoteDatasource _ds;
  DocumentsRepositoryImpl(this._ds);

  @override
  Future<(List<DocumentEntity>, Failure?)> fetchDocuments() async {
    try {
      final models = await _ds.fetchDocuments();
      return (models.map((m) => m.toEntity()).toList(), null);
    } on Failure catch (f) { return (<DocumentEntity>[], f); }
    catch (e) { return (<DocumentEntity>[], UnknownFailure(e.toString())); }
  }
}
