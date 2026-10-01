import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/features/hours/data/hours_repository.dart';
import 'package:uni_cronos/features/hours/domain/hours.dart';

void main() {
  late InMemoryHoursRepository repository;

  setUp(() => repository = InMemoryHoursRepository());
  tearDown(() => repository.dispose());

  test('CA-01: the initial data is 130 of 200 complementary hours and 45 of '
      '100 extension hours', () async {
    final snapshot = await repository.watch().first;

    final complementary = snapshot.of(HourCategory.complementary);
    final extension = snapshot.of(HourCategory.extension);
    expect((complementary.hours, complementary.goal), (130, 200));
    expect((extension.hours, extension.goal), (45, 100));
    expect(complementary.ratio, closeTo(0.65, 1e-9));
    expect(extension.ratio, closeTo(0.45, 1e-9));
  });

  test('CA-02: the recent list is newest first', () async {
    final snapshot = await repository.watch().first;

    expect(
      [for (final c in snapshot.recent) (c.title, c.hours, c.category)],
      [
        ('Workshop de Tecnologia Comunitária', 15, HourCategory.extension),
        ('Seminário Avançado de Python', 8, HourCategory.complementary),
        ('University Game Jam 2024', 24, HourCategory.complementary),
      ],
    );
  });

  test('CA-04: the summary is 175 hours, 3 certificates and 58% of the '
      'goal', () async {
    final summary = (await repository.watch().first).summary;

    expect(
      (summary.totalHours, summary.certificates, summary.goalPercent),
      (175, 3, 58),
    );
  });

  test('CA-03: adding a certificate adds its hours and puts it first, for '
      'current and later listeners', () async {
    final current = repository.watch().skip(1).first;
    await repository.add(
      ApprovedCertificate(
        id: 'new',
        title: 'Certificado Game Jam',
        category: HourCategory.complementary,
        hours: 10,
        approvedAt: DateTime(2026, 10, 1),
      ),
    );

    for (final snapshot in [await current, await repository.watch().first]) {
      expect(snapshot.of(HourCategory.complementary).hours, 140);
      expect(snapshot.recent.first.title, 'Certificado Game Jam');
      expect(snapshot.summary.certificates, 4);
    }
  });

  test('CA-04: the goal percent rounds down, so 176 of 300 hours is '
      '58%', () async {
    await repository.add(
      ApprovedCertificate(
        id: 'one-hour',
        title: 'Palestra',
        category: HourCategory.extension,
        hours: 1,
        approvedAt: DateTime(2026, 10, 1),
      ),
    );

    final summary = (await repository.watch().first).summary;
    expect((summary.totalHours, summary.goalPercent), (176, 58));
  });

  test('CA-05: the progress ratio never goes past 1.0', () {
    const over = CategoryProgress(
      category: HourCategory.complementary,
      hours: 210,
      goal: 200,
    );

    expect(over.ratio, 1.0);
    expect(over.hours, 210);
  });

  test('CA-01: every repository starts from the same initial data', () async {
    await repository.add(
      ApprovedCertificate(
        id: 'new',
        title: 'Outro',
        category: HourCategory.extension,
        hours: 5,
        approvedAt: DateTime(2026, 10, 1),
      ),
    );

    final fresh = InMemoryHoursRepository();
    addTearDown(fresh.dispose);
    final snapshot = await fresh.watch().first;
    expect(snapshot.of(HourCategory.extension).hours, 45);
    expect(snapshot.recent, hasLength(3));
  });
}
