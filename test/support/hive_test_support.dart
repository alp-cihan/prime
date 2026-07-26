import 'dart:io';

import 'package:hive_ce/hive_ce.dart';
import 'package:prime/core/persistence/hive_type_ids.dart';
import 'package:prime/hive_registrar.g.dart';

/// Shared real-Hive test harness — no mocking. Each test gets its own
/// temp directory so tests never see each other's data; [reopen] simulates
/// an app restart against the *same* on-disk directory.
class HiveTestSupport {
  HiveTestSupport._(this._tempDir);

  final Directory _tempDir;

  static HiveTestSupport start() {
    final tempDir = Directory.systemTemp.createTempSync('prime_hive_test_');
    Hive.init(tempDir.path);
    _registerAdaptersIfNeeded();
    return HiveTestSupport._(tempDir);
  }

  /// Closes Hive and re-initializes against the same directory, as if the
  /// app process had restarted. Callers must reopen any boxes they need
  /// afterwards.
  Future<void> reopen() async {
    await Hive.close();
    Hive.init(_tempDir.path);
    _registerAdaptersIfNeeded();
  }

  Future<void> dispose() async {
    await Hive.close();
    if (_tempDir.existsSync()) {
      _tempDir.deleteSync(recursive: true);
    }
  }

  static void _registerAdaptersIfNeeded() {
    if (Hive.isAdapterRegistered(HiveTypeIds.quest)) return;
    Hive.registerAdapters();
  }
}
