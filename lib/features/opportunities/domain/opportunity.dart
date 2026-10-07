import '../../hours/domain/hours.dart';

enum OpportunityKind { course, event }

enum Modality { online, presencial, hibrido }

/// A course or event in which the student earns a certificate of hours.
class Opportunity {
  const Opportunity({
    required this.id,
    required this.kind,
    required this.category,
    required this.title,
    required this.description,
    required this.provider,
    required this.modality,
    required this.hours,
    this.startsAt,
    this.url,
    this.featured = false,
  });

  final String id;
  final OpportunityKind kind;
  final HourCategory category;
  final String title;
  final String description;
  final String provider;
  final Modality modality;
  final int hours;
  final DateTime? startsAt;

  /// Where to sign up; always https.
  final Uri? url;
  final bool featured;
}

/// The chips above the list: one at a time.
enum OpportunityFilter { all, courses, events, extension, complementary }

/// The opportunities shown for [filter] and [query]: both apply (AND), the
/// search ignores case and accents and looks at the title, the description
/// and who offers it. The featured one first, then by start date.
List<Opportunity> visibleOpportunities(
  List<Opportunity> all, {
  required OpportunityFilter filter,
  required String query,
}) {
  final needle = foldForSearch(query.trim());
  bool kept(Opportunity o) => switch (filter) {
    OpportunityFilter.all => true,
    OpportunityFilter.courses => o.kind == OpportunityKind.course,
    OpportunityFilter.events => o.kind == OpportunityKind.event,
    OpportunityFilter.extension => o.category == HourCategory.extension,
    OpportunityFilter.complementary => o.category == HourCategory.complementary,
  };
  bool found(Opportunity o) =>
      needle.isEmpty ||
      foldForSearch(
        '${o.title} ${o.description} ${o.provider}',
      ).contains(needle);
  final far = DateTime(9999);
  return all.where((o) => kept(o) && found(o)).toList()..sort((a, b) {
    if (a.featured != b.featured) return a.featured ? -1 : 1;
    return (a.startsAt ?? far).compareTo(b.startsAt ?? far);
  });
}

const _accented = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
const _plain = 'aaaaaeeeeiiiiooooouuuucn';

/// Lower case without accents, so "Extensão" is found by "extensao".
String foldForSearch(String text) {
  final buffer = StringBuffer();
  for (final char in text.toLowerCase().split('')) {
    final index = _accented.indexOf(char);
    buffer.write(index < 0 ? char : _plain[index]);
  }
  return buffer.toString();
}
