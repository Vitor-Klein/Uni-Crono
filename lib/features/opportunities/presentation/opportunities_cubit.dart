import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/opportunity_repository.dart';
import '../domain/opportunity.dart';

class OpportunitiesState {
  const OpportunitiesState({
    this.all,
    this.failed = false,
    this.filter = OpportunityFilter.all,
    this.query = '',
  });

  /// Null while loading.
  final List<Opportunity>? all;
  final bool failed;
  final OpportunityFilter filter;
  final String query;

  List<Opportunity> get visible =>
      visibleOpportunities(all ?? const [], filter: filter, query: query);

  OpportunitiesState copyWith({
    List<Opportunity>? all,
    bool? failed,
    OpportunityFilter? filter,
    String? query,
  }) => OpportunitiesState(
    all: all ?? this.all,
    failed: failed ?? this.failed,
    filter: filter ?? this.filter,
    query: query ?? this.query,
  );
}

/// The catalog, with the filter and the search the student chose.
class OpportunitiesCubit extends Cubit<OpportunitiesState> {
  OpportunitiesCubit(this._repository) : super(const OpportunitiesState()) {
    load();
  }

  final OpportunityRepository _repository;

  Future<void> load() async {
    emit(OpportunitiesState(filter: state.filter, query: state.query));
    try {
      final all = await _repository.list();
      if (!isClosed) emit(state.copyWith(all: all, failed: false));
    } on OpportunityLoadFailure {
      if (!isClosed) emit(state.copyWith(failed: true));
    }
  }

  void setFilter(OpportunityFilter filter) =>
      emit(state.copyWith(filter: filter));

  void setQuery(String query) => emit(state.copyWith(query: query));
}
