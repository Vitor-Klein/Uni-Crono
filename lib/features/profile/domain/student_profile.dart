/// The student as the profile shows them.
class StudentProfile {
  const StudentProfile({
    required this.fullName,
    required this.email,
    required this.institutionId,
    required this.course,
    required this.term,
  });

  final String fullName;
  final String email;
  final String institutionId;
  final String course;
  final int term;

  /// First letters of the first and the last name: "Ana Souza" -> "AS".
  String get initials {
    final words = fullName.trim().split(RegExp(r'\s+'));
    if (words.first.isEmpty) return '';
    final first = words.first[0];
    final last = words.length > 1 ? words.last[0] : '';
    return (first + last).toUpperCase();
  }
}
