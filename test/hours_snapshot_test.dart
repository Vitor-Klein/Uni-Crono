import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/features/hours/domain/hours.dart';

import 'app_harness.dart';

void main() {
  final demo = HoursSnapshot.fromCertificates(demoCertificates());

  test('CA-01: the demo certificates give 130 of 35 complementary hours and '
      '45 of 200 extension hours', () {
    final complementary = demo.of(HourCategory.complementary);
    final extension = demo.of(HourCategory.extension);
    expect((complementary.hours, complementary.goal), (130, 35));
    expect((extension.hours, extension.goal), (45, 200));
    expect(complementary.ratio, 1.0);
    expect(extension.ratio, closeTo(0.225, 1e-9));
  });

  test('CA-02: the recent list is newest first', () {
    expect(
      [for (final c in demo.recent.take(3)) (c.title, c.hours, c.category)],
      [
        ('Workshop de Tecnologia Comunitária', 15, HourCategory.extension),
        ('Seminário Avançado de Python', 8, HourCategory.complementary),
        ('University Game Jam 2024', 24, HourCategory.complementary),
      ],
    );
  });

  test('CA-04: the summary counts every hour and certificate: 175 hours, 5 '
      'certificates and 74% of the goal', () {
    final summary = demo.summary;

    expect(
      (summary.totalHours, summary.certificates, summary.goalPercent),
      (175, 5, 74),
    );
  });

  test('CA-04: the goal percent rounds down, so 176 of 235 hours is 74%', () {
    final summary = HoursSnapshot.fromCertificates([
      ...demoCertificates(),
      ApprovedCertificate(
        id: 'one-hour',
        title: 'Palestra',
        category: HourCategory.extension,
        hours: 1,
        approvedAt: DateTime(2026, 10, 1),
      ),
    ]).summary;

    expect((summary.totalHours, summary.goalPercent), (176, 74));
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

  test('CA-07: a student without certificates has 0 of 35 and 0 of 200 '
      'hours, nothing recent and 0% of the goal', () {
    final empty = HoursSnapshot.fromCertificates(const []);

    expect(empty.of(HourCategory.complementary).hours, 0);
    expect(empty.of(HourCategory.complementary).goal, 35);
    expect(empty.of(HourCategory.extension).hours, 0);
    expect(empty.of(HourCategory.extension).goal, 200);
    expect(empty.recent, isEmpty);
    expect(
      (
        empty.summary.totalHours,
        empty.summary.certificates,
        empty.summary.goalPercent,
      ),
      (0, 0, 0),
    );
  });

  test('CA-08: 10 complementary and 15 extension hours give 10 of 35 and 15 '
      'of 200, newest first', () {
    final snapshot = HoursSnapshot.fromCertificates([
      ApprovedCertificate(
        id: 'a',
        title: 'Antigo',
        category: HourCategory.complementary,
        hours: 10,
        approvedAt: DateTime(2026, 9, 1),
      ),
      ApprovedCertificate(
        id: 'b',
        title: 'Novo',
        category: HourCategory.extension,
        hours: 15,
        approvedAt: DateTime(2026, 10, 1),
      ),
    ]);

    expect(snapshot.of(HourCategory.complementary).hours, 10);
    expect(snapshot.of(HourCategory.extension).hours, 15);
    expect([for (final c in snapshot.recent) c.title], ['Novo', 'Antigo']);
  });
}
