/// The two kinds of hours a student must complete.
enum HourCategory { complementary, extension }

/// A certificate whose hours already count.
class ApprovedCertificate {
  const ApprovedCertificate({
    required this.id,
    required this.title,
    required this.category,
    required this.hours,
    required this.approvedAt,
  });

  final String id;
  final String title;
  final HourCategory category;
  final int hours;
  final DateTime approvedAt;
}

/// How far a category is from its goal.
class CategoryProgress {
  const CategoryProgress({
    required this.category,
    required this.hours,
    required this.goal,
  });

  final HourCategory category;
  final int hours;
  final int goal;

  /// Share of the goal reached, capped at 1.0 — hours above the goal still
  /// count in [hours].
  double get ratio => (hours / goal).clamp(0.0, 1.0);
}

/// Totals across both categories.
class HoursSummary {
  const HoursSummary({
    required this.totalHours,
    required this.certificates,
    required this.goalPercent,
  });

  final int totalHours;
  final int certificates;

  /// Percent of the combined goal, rounded down.
  final int goalPercent;
}

/// Everything the screens show about hours, at one moment.
class HoursSnapshot {
  const HoursSnapshot({
    required this.progress,
    required this.recent,
    required this.summary,
  });

  final List<CategoryProgress> progress;

  /// Approved certificates, newest first.
  final List<ApprovedCertificate> recent;
  final HoursSummary summary;

  CategoryProgress of(HourCategory category) =>
      progress.firstWhere((p) => p.category == category);
}
