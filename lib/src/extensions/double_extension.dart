extension DoubleExtension on num {
  String get shorten {
    return switch (abs()) {
      >= 1000000000000 =>
        "${(this / 1000000000000).toStringAsFixedNotRound(2)}T",
      >= 1000000000 => "${(this / 1000000000).toStringAsFixedNotRound(2)}B",
      >= 1000000 => "${(this / 1000000).toStringAsFixedNotRound(2)}M",
      >= 1000 => "${(this / 1000).toStringAsFixedNotRound(1)}K",
      _ => toStringAsFixedNotRound(2),
    };
  }

  //--------------------------------------------------------------------------------------------
  String toStringAsFixedNotRound(int fractionDigits) {
    //? COULD ADD AUTO FRACTION DIGITS ADJUSTMENTS
    if (isInfinite) return '∞';
    if (isNaN) return 'NaN';

    int integerValue = toInt();
    String integerPart = integerValue.toString();
    if (fractionDigits == 0) return integerPart;

    // Here we are ensuring the integer part to conserve the sign of the number
    // because in case the number is between -1 and 0, the integer part will be 0
    // and 0 is not negative, so we need to add the sign to the integer part
    if (this < 0 && !integerPart.startsWith('-')) {
      integerPart = '-$integerPart';
    }

    // Avoid using the following variants to get the decimal part because implies rounding, somehow dart does some floating point rounding for some values:
    // num decimalValue = this % 1;
    // num decimalValue = this - integerValue;

    // Instead use string splitting which ensure we get the exact decimal part without rounding
    final splitParts = toString().split('.');
    if (splitParts.length == 1) return integerPart;

    String decimalPart = splitParts.lastOrNull ?? '';
    if (decimalPart.length >= fractionDigits) {
      decimalPart = decimalPart.substring(0, fractionDigits);
    } else {
      decimalPart = decimalPart.padRight(
        fractionDigits - decimalPart.length,
        '0',
      );
    }
    return '$integerPart.$decimalPart';
  }
}
