import 'package:hive_ce/hive.dart';

import '../../../../bootstrap/hive_bootstrap.dart';
import '../../../../core/persistence/hive_box_names.dart';

/// Deletes every Hive box Prime owns and reopens them empty, returning the
/// app to first-run state (Phase 14). Deliberately bypasses every feature's
/// repository interface and talks to Hive directly — unlike every other
/// mutation in this app, "clear everything" is not a domain operation any
/// single feature can express; it is cross-cutting infrastructure, exactly
/// the kind of exception CLAUDE.md's repository boundaries are meant to
/// isolate to one place instead of leaking into feature code.
///
/// [HiveBoxNames.all] is the single source of truth for which boxes exist —
/// "delete only Prime-owned local data" holds by construction, since nothing
/// outside that list is ever touched.
///
/// Does not, by itself, reset any in-memory Riverpod state — the caller
/// (`ClearDataController`) is responsible for rebuilding the whole provider
/// tree afterward (see `AppRestartScope`), which is what actually guarantees
/// "never leave providers/controllers in a corrupted state": every provider
/// and `keepAlive` controller referencing a now-deleted `Box` is thrown away
/// and rebuilt fresh against the newly (empty) reopened ones, rather than
/// trying to individually invalidate each one.
class ClearLocalDataUseCase {
  const ClearLocalDataUseCase();

  Future<void> execute() async {
    for (final name in HiveBoxNames.all) {
      if (await Hive.boxExists(name)) {
        await Hive.deleteBoxFromDisk(name);
      }
    }
    // Deliberately reopenAllBoxes(), not the full bootstrapHive() — see that
    // function's own doc for why re-running Hive.initFlutter() here would be
    // both unnecessary and untestable.
    await reopenAllBoxes();
  }
}
