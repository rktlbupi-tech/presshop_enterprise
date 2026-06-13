import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/earning_entity.dart';
import '../../domain/repositories/earnings_repository.dart';

abstract class EarningsEvent extends Equatable {
  const EarningsEvent();
  @override List<Object?> get props => [];
}
class FetchEarnings extends EarningsEvent { const FetchEarnings(); }

abstract class EarningsState extends Equatable {
  const EarningsState();
  @override List<Object?> get props => [];
}
class EarningsInitial extends EarningsState { const EarningsInitial(); }
class EarningsLoading extends EarningsState { const EarningsLoading(); }
class EarningsLoaded extends EarningsState {
  final List<EarningEntity> earnings;
  final double ytd;
  const EarningsLoaded({required this.earnings, required this.ytd});
  @override List<Object?> get props => [earnings, ytd];
}
class EarningsError extends EarningsState {
  final String message;
  const EarningsError(this.message);
  @override List<Object?> get props => [message];
}

class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  final EarningsRepository _repo;
  EarningsBloc(this._repo) : super(const EarningsInitial()) {
    on<FetchEarnings>(_onFetch);
  }

  Future<void> _onFetch(FetchEarnings e, Emitter<EarningsState> emit) async {
    emit(const EarningsLoading());
    final (earnings, failure) = await _repo.fetchEarnings();
    if (failure != null) { emit(EarningsError(failure.message)); return; }
    final (ytd, _) = await _repo.fetchYtd();
    emit(EarningsLoaded(earnings: earnings, ytd: ytd));
  }
}
