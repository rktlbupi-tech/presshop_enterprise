import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/documents_repository.dart';

abstract class DocumentsEvent extends Equatable {
  const DocumentsEvent();
  @override List<Object?> get props => [];
}
class FetchDocuments extends DocumentsEvent { const FetchDocuments(); }

abstract class DocumentsState extends Equatable {
  const DocumentsState();
  @override List<Object?> get props => [];
}
class DocumentsInitial extends DocumentsState { const DocumentsInitial(); }
class DocumentsLoading extends DocumentsState { const DocumentsLoading(); }
class DocumentsLoaded extends DocumentsState {
  final List<DocumentEntity> documents;
  const DocumentsLoaded(this.documents);
  @override List<Object?> get props => [documents];
}
class DocumentsError extends DocumentsState {
  final String message;
  const DocumentsError(this.message);
  @override List<Object?> get props => [message];
}

class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  final DocumentsRepository _repo;
  DocumentsBloc(this._repo) : super(const DocumentsInitial()) {
    on<FetchDocuments>(_onFetch);
  }

  Future<void> _onFetch(FetchDocuments e, Emitter<DocumentsState> emit) async {
    emit(const DocumentsLoading());
    final (docs, failure) = await _repo.fetchDocuments();
    if (failure != null) { emit(DocumentsError(failure.message)); return; }
    emit(DocumentsLoaded(docs));
  }
}
