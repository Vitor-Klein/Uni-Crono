import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../hours/domain/hours.dart';
import '../domain/opportunity.dart';
import 'opportunity_repository.dart';

/// The published opportunities, from the `opportunities` table. The table
/// only lets students read published rows; the query asks for them too.
class SupabaseOpportunityRepository implements OpportunityRepository {
  SupabaseOpportunityRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Opportunity>> list() async {
    final List<Map<String, dynamic>> rows;
    try {
      rows = await _client
          .from('opportunities')
          .select(
            'id, kind, hour_category, title, description, provider, '
            'modality, hours, starts_at, url, featured',
          )
          .eq('published', true);
    } catch (e) {
      debugPrint('Opportunities load failed: ${e.runtimeType}');
      throw const OpportunityLoadFailure();
    }
    return [
      for (final row in rows)
        if (_parse(row) case final opportunity?) opportunity,
    ];
  }

  /// A row is external data: one the app does not understand is left out
  /// (the rest of the catalog still shows), and only https links are kept.
  static Opportunity? _parse(Map<String, dynamic> row) {
    try {
      final hours = row['hours'] as int;
      if (hours < 1 || hours > 999) return null;
      final url = Uri.tryParse(row['url'] as String? ?? '');
      final startsAt = row['starts_at'] as String?;
      return Opportunity(
        id: row['id'] as String,
        kind: OpportunityKind.values.byName(row['kind'] as String),
        category: HourCategory.values.byName(row['hour_category'] as String),
        title: row['title'] as String,
        description: row['description'] as String,
        provider: row['provider'] as String,
        modality: Modality.values.byName(row['modality'] as String),
        hours: hours,
        startsAt: startsAt == null ? null : DateTime.parse(startsAt),
        url: url != null && url.isScheme('https') && url.host.isNotEmpty
            ? url
            : null,
        featured: row['featured'] as bool? ?? false,
      );
    } catch (e) {
      debugPrint('Opportunity row skipped: ${e.runtimeType}');
      return null;
    }
  }
}
