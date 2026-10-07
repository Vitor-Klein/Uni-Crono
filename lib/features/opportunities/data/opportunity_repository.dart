import '../domain/opportunity.dart';

/// The catalog could not be loaded (no network, server error).
class OpportunityLoadFailure implements Exception {
  const OpportunityLoadFailure();
}

/// The published opportunities.
abstract class OpportunityRepository {
  /// Throws [OpportunityLoadFailure] when the catalog cannot be loaded.
  Future<List<Opportunity>> list();
}
