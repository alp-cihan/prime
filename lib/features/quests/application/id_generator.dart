import 'dart:math';

/// Testability seam for generating a new quest's id — mirrors the `Clock`
/// abstraction's pattern so `CreateQuestUseCase` tests can inject a
/// deterministic id instead of a random one.
abstract class IdGenerator {
  String generate();
}

/// Generates an RFC 4122 version-4-shaped UUID using [Random.secure()].
/// Implemented locally rather than pulling in the `uuid` package — the
/// approved architecture doesn't call for it, and a v4 UUID is a few lines
/// of bit-twiddling over a secure random source, not worth a new dependency
/// for a single call site.
class UuidV4IdGenerator implements IdGenerator {
  const UuidV4IdGenerator();

  @override
  String generate() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));

    // Version 4: set the 4 most-significant bits of byte 6 to 0100.
    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    // Variant 1 (RFC 4122): set the 2 most-significant bits of byte 8 to 10.
    bytes[8] = (bytes[8] & 0x3F) | 0x80;

    String hex(int start, int end) => bytes
        .sublist(start, end)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
  }
}
