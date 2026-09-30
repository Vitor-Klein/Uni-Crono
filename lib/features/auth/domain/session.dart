import 'package:flutter/foundation.dart';

/// Who is signed in on this device. The password is never part of it.
@immutable
class Session {
  const Session({required this.email, required this.institutionId});

  final String email;
  final String institutionId;

  @override
  bool operator ==(Object other) =>
      other is Session &&
      other.email == email &&
      other.institutionId == institutionId;

  @override
  int get hashCode => Object.hash(email, institutionId);
}
