const _accented = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
const _plain = 'aaaaaeeeeiiiiooooouuuucn';

/// Lower case without accents, so "Extensão" matches "extensao".
String foldText(String text) {
  final buffer = StringBuffer();
  for (final char in text.toLowerCase().split('')) {
    final index = _accented.indexOf(char);
    buffer.write(index < 0 ? char : _plain[index]);
  }
  return buffer.toString();
}
