/// What a new student fills in to create an account.
class SignUpData {
  const SignUpData({
    required this.fullName,
    required this.institutionId,
    required this.course,
    required this.term,
    required this.email,
    required this.password,
  });

  final String fullName;
  final String institutionId;
  final String course;
  final int term;
  final String email;
  final String password;
}
