import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Initializes the Hive CE storage engine. No boxes are opened here yet —
/// Phase 0 only proves the engine initializes cleanly; boxes/adapters are
/// registered as real entities land in later phases.
Future<void> bootstrapHive() async {
  await Hive.initFlutter();
}
