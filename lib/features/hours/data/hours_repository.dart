import 'package:rxdart/rxdart.dart';

import '../domain/hours.dart';

/// Where the student's hours come from.
abstract class HoursRepository {
  /// The current hours, and every change after that.
  Stream<HoursSnapshot> watch();

  Future<void> add(ApprovedCertificate certificate);

  void dispose();
}

/// The prototype's hours, in memory: every instance starts from the same
/// fictitious history.
class InMemoryHoursRepository implements HoursRepository {
  InMemoryHoursRepository() : _certificates = _initialCertificates() {
    _subject = BehaviorSubject.seeded(_snapshot());
  }

  static const _goals = {
    HourCategory.complementary: 200,
    HourCategory.extension: 100,
  };

  /// Hours earned before the certificates below.
  static const _baseHours = {
    HourCategory.complementary: 98,
    HourCategory.extension: 30,
  };

  static List<ApprovedCertificate> _initialCertificates() => [
    ApprovedCertificate(
      id: 'community-tech-workshop',
      title: 'Workshop de Tecnologia Comunitária',
      category: HourCategory.extension,
      hours: 15,
      approvedAt: DateTime(2026, 9, 20),
    ),
    ApprovedCertificate(
      id: 'advanced-python-seminar',
      title: 'Seminário Avançado de Python',
      category: HourCategory.complementary,
      hours: 8,
      approvedAt: DateTime(2026, 9, 12),
    ),
    ApprovedCertificate(
      id: 'university-game-jam-2024',
      title: 'University Game Jam 2024',
      category: HourCategory.complementary,
      hours: 24,
      approvedAt: DateTime(2026, 8, 30),
    ),
  ];

  final List<ApprovedCertificate> _certificates;
  late final BehaviorSubject<HoursSnapshot> _subject;

  @override
  Stream<HoursSnapshot> watch() => _subject.stream;

  @override
  Future<void> add(ApprovedCertificate certificate) async {
    _certificates.add(certificate);
    _subject.add(_snapshot());
  }

  @override
  void dispose() => _subject.close();

  HoursSnapshot _snapshot() {
    final recent = [..._certificates]
      ..sort((a, b) => b.approvedAt.compareTo(a.approvedAt));
    final progress = [
      for (final category in HourCategory.values)
        CategoryProgress(
          category: category,
          hours:
              _baseHours[category]! +
              _certificates
                  .where((c) => c.category == category)
                  .fold(0, (sum, c) => sum + c.hours),
          goal: _goals[category]!,
        ),
    ];
    final totalHours = progress.fold(0, (sum, p) => sum + p.hours);
    final totalGoal = progress.fold(0, (sum, p) => sum + p.goal);
    return HoursSnapshot(
      progress: progress,
      recent: recent,
      summary: HoursSummary(
        totalHours: totalHours,
        certificates: _certificates.length,
        goalPercent: totalHours * 100 ~/ totalGoal,
      ),
    );
  }
}
