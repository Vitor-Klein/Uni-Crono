/// A university the student can sign in with.
class Institution {
  const Institution({required this.id, required this.name});

  final String id;
  final String name;
}

/// The universities the prototype offers.
abstract final class Institutions {
  static const all = [
    Institution(id: 'utfpr', name: 'UTFPR'),
    Institution(id: 'ufpr', name: 'UFPR'),
    Institution(id: 'pucpr', name: 'PUCPR'),
    Institution(id: 'uel', name: 'UEL'),
  ];
}
