/// Presentation-only thousands-separator formatting (e.g. "12,450") — no
/// intl dependency; XP totals are unbounded and must stay readable without
/// overflowing a narrow screen.
String formatXp(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return negative ? '-$buffer' : buffer.toString();
}
