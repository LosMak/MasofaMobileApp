import 'package:flutter/services.dart';

class RemoveLeadingZeroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text == '-0') return oldValue;
    if (text == '0') return newValue;
    if (text.isEmpty) return newValue;

    final stripped = text.replaceFirst(RegExp(r'^0+'), '');

    return newValue.copyWith(
      text: stripped.isEmpty ? '0' : stripped,
      selection: TextSelection.collapsed(
          offset: stripped.isEmpty ? 1 : stripped.length),
    );
  }
}
