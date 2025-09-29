extension MyStringExtensions on String {
  String extractNumbers() => replaceAll(RegExp(r'[^0-9]'), '');

  String get dateFormat {
    final index = indexOf('T');
    if (index == -1) return this;

    return substring(0, indexOf('T'));
  }
}
