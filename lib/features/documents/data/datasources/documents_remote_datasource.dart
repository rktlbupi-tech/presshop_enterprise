import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/document_model.dart';

class DocumentsRemoteDatasource {
  final ApiClient _client;
  DocumentsRemoteDatasource(this._client);

  Future<List<DocumentModel>> fetchDocuments() async {
    final res = await _client.get(ApiEndpoints.documents);
    final data = res.data['data'] as List<dynamic>? ?? [];
    return data.map((e) => DocumentModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
