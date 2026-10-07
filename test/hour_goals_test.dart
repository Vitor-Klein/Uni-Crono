import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uni_cronos/features/hours/domain/hours.dart';
import 'package:uni_cronos/features/hours/presentation/dashboard_page.dart';
import 'package:uni_cronos/features/profile/presentation/profile_page.dart';

import 'app_harness.dart';

Finder _inDashboard(Finder finder) =>
    find.descendant(of: find.byType(DashboardPage), matching: finder);

void main() {
  group('goals', () {
    final demo = HoursSnapshot.fromCertificates(demoCertificates());

    test('CA-01: the demo gives 130 of 35 complementary hours, full, and 45 '
        'of 200 extension hours', () {
      final complementary = demo.of(HourCategory.complementary);
      final extension = demo.of(HourCategory.extension);

      expect((complementary.hours, complementary.goal), (130, 35));
      expect(complementary.ratio, 1.0);
      expect(complementary.percent, 100);
      expect((extension.hours, extension.goal), (45, 200));
      expect(extension.ratio, closeTo(0.225, 1e-9));
      expect(extension.percent, 22);
    });

    test('CA-03: without certificates the goals are 35 and 200 hours and the '
        'summary is at 0%', () {
      final empty = HoursSnapshot.fromCertificates(const []);

      expect(empty.of(HourCategory.complementary).goal, 35);
      expect(empty.of(HourCategory.extension).goal, 200);
      expect(empty.summary.goalPercent, 0);
    });

    test('CA-04: the card percent rounds down and stops at 100', () {
      const half = CategoryProgress(
        category: HourCategory.extension,
        hours: 45,
        goal: 200,
      );
      const over = CategoryProgress(
        category: HourCategory.complementary,
        hours: 130,
        goal: 35,
      );

      expect(half.percent, 22);
      expect(over.percent, 100);
    });
  });

  testWidgets('CA-01: the dashboard shows 35 and 200 hours as the goals, with '
      '100% and 22%', (tester) async {
    await pumpRoutedApp(tester);

    expect(_inDashboard(find.text('35 no total')), findsOneWidget);
    expect(_inDashboard(find.text('200 no total')), findsOneWidget);
    expect(_inDashboard(find.text('100%')), findsOneWidget);
    expect(_inDashboard(find.text('22%')), findsOneWidget);
  });

  testWidgets('CA-02: the profile summary shows 175 h, 5 and 74%', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpRoutedApp(tester);
    await tester.tap(navLabel('Perfil'));
    await tester.pumpAndSettle();

    Finder inProfile(Finder f) =>
        find.descendant(of: find.byType(ProfilePage), matching: f);
    expect(inProfile(find.text('175 h')), findsOneWidget);
    expect(inProfile(find.text('5')), findsOneWidget);
    expect(inProfile(find.text('74%')), findsOneWidget);
  });
}
