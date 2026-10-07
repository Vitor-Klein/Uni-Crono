import '../../../core/utils/fold_text.dart';
import '../../hours/domain/hours.dart';
import 'certificate_file_rules.dart';

/// What the text of a certificate says.
class CertificateReading {
  const CertificateReading({
    required this.hours,
    required this.category,
    required this.title,
    required this.issuer,
  });

  /// Null when the text states no workload.
  final int? hours;
  final HourCategory category;
  final String title;
  final String? issuer;
}

const _minHours = 1;
const _maxHours = 999;
const _maxTitle = 120;

/// Folded (lower case, no accents) with single spaces.
String _plain(String text) =>
    foldText(text).replaceAll(RegExp(r'\s+'), ' ').trim();

// A number right after "carga horaria", with at most 40 other characters.
final _workload = RegExp(
  r'carga horaria\D{0,40}?(?<![\d/.,:])(\d{1,4})(?![\d/])',
);

// "8h", "10h30", "20 horas", "12 hrs", "40 (quarenta) horas".
final _duration = RegExp(
  r'(?<![\d/.,:])(\d{1,4})\s*(?:\([^)\d]{1,30}\)\s*)?'
  r'(?:h(?:\d{2})?|horas?|hrs?)\b',
);

// Words that make "8h" a time of day: "as 14h", "das 8h", "ate as 12h".
final _clockBefore = RegExp(r'\b(?:as|das|ate|partir das)\s*$');

int? _inRange(int hours) =>
    hours >= _minHours && hours <= _maxHours ? hours : null;

/// The workload of the certificate, or null when it is not stated. The number
/// after "carga horária" wins; otherwise the first duration that is not a
/// time of day. Minutes are dropped; outside 1–999 is no answer.
int? findHours(String text) {
  final plain = _plain(text);
  final workload = _workload.firstMatch(plain);
  if (workload != null) return _inRange(int.parse(workload.group(1)!));
  for (final match in _duration.allMatches(plain)) {
    if (_clockBefore.hasMatch(plain.substring(0, match.start))) continue;
    return _inRange(int.parse(match.group(1)!));
  }
  return null;
}

/// Extension when the text speaks of extension; complementary otherwise.
HourCategory classifyHours(String text) =>
    RegExp(r'\bextens(?:ao|ionista)').hasMatch(_plain(text))
    ? HourCategory.extension
    : HourCategory.complementary;

const _marker = r'(?:participou d[oa]s?|concluiu o curso|evento)';
final _quoted = RegExp(
  _marker + r'\s+(?:[^\s"“”]+\s+)?["“]([^"“”]{2,300})["”]',
  caseSensitive: false,
);
final _unquoted = RegExp(
  r'(?:participou d[oa]s?|concluiu o curso)\s+([^,.;"“”]{2,300})',
  caseSensitive: false,
);

String _cleanTitle(String title) {
  var clean = title.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (clean.length > _maxTitle) {
    final cut = clean.substring(0, _maxTitle);
    final space = cut.lastIndexOf(' ');
    clean = space > 0 ? cut.substring(0, space) : cut;
  }
  return clean.isEmpty ? clean : clean[0].toUpperCase() + clean.substring(1);
}

/// What the certificate is for: the quoted name after the marker, else the
/// text up to the next comma or period, else the file name.
String findTitle(String text, {required String fileName}) {
  final flat = text.replaceAll(RegExp(r'\s+'), ' ');
  for (final pattern in [_quoted, _unquoted]) {
    final match = pattern.firstMatch(flat);
    if (match != null) {
      final title = _cleanTitle(match.group(1)!);
      if (title.isNotEmpty) return title;
    }
  }
  return _cleanTitle(titleFromFileName(fileName));
}

/// The student's institution, when the certificate names it.
String? findIssuer(String text, {required String institution}) =>
    institution.isNotEmpty &&
        RegExp(
          r'\b' + RegExp.escape(institution) + r'\b',
          caseSensitive: false,
        ).hasMatch(text)
    ? institution
    : null;

CertificateReading readCertificate(
  String text, {
  required String fileName,
  required String institution,
}) => CertificateReading(
  hours: findHours(text),
  category: classifyHours(text),
  title: findTitle(text, fileName: fileName),
  issuer: findIssuer(text, institution: institution),
);
