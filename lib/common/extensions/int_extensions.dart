import 'package:dala_ishchisi/common/localization/localization.dart';

extension Convert on int {
  String toReadable() {
    // 1234 -> 1,234
    // 12345 -> 12,345

    final String numStr = toString();
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < numStr.length; i++) {
      if (i > 0 && (numStr.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(numStr[i]);
    }

    return buffer.toString();
  }

  String toReadableDistance() {
    // 123 -> "123 m"
    // 12345 -> "12,3 km"

    if (this < 1000) {
      return '$this ${Words.m.str}';
    } else {
      final double kilometers = this / 1000.0;
      final String formattedDistance =
          kilometers.toStringAsFixed(1).replaceAll('.', ',');
      return '$formattedDistance ${Words.km.str}';
    }
  }
}
