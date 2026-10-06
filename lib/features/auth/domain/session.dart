import 'package:flutter/foundation.dart';

/// Who is signed in. The password is never part of it.
@immutable
class Session {
  const Session({
    required this.userId,
    required this.email,
    required this.institutionId,
  });

  final String userId;
  final String email;
  final String institutionId;

  @override
  bool operator ==(Object other) =>
      other is Session &&
      other.userId == userId &&
      other.email == email &&
      other.institutionId == institutionId;

  @override
  int get hashCode => Object.hash(userId, email, institutionId);
}
