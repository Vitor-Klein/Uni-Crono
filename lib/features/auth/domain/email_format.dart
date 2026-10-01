final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Whether [email] looks like an e-mail address. A format check only: it
/// says nothing about the address existing.
bool isValidEmail(String email) => _emailPattern.hasMatch(email);
