/// Current persisted local-storage schema version.
///
/// This is a marker, not an active migration engine: Phase 3 introduces no
/// migrations, since there is no prior persisted schema to migrate from.
/// Bump this constant the first time a real migration is introduced, and
/// add the migration step where [kSchemaVersion] is read during bootstrap
/// (see `hive_bootstrap.dart`) — that is the intended migration boundary.
const int kSchemaVersion = 1;
