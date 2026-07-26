import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;
import 'package:prime/core/persistence/hive_box_names.dart';
import 'package:prime/core/providers/persistence_providers.dart';
import 'package:prime/features/quests/data/models/quest_hive_model.dart';
import 'package:prime/features/quests/data/models/quest_progress_hive_model.dart';
import 'package:prime/features/xp_ledger/data/models/xp_transaction_hive_model.dart';

/// Builds a [ProviderContainer] wired to real, freshly-opened temporary Hive
/// boxes (via [HiveTestSupport]) instead of the app-bootstrap-owned boxes —
/// exactly the override Phase 4's tests are asked to use. Call
/// `HiveTestSupport.start()` first.
Future<ProviderContainer> buildTestContainer({
  List<Override> extraOverrides = const [],
}) async {
  final questBox = await Hive.openBox<QuestHiveModel>(HiveBoxNames.quests);
  final progressBox = await Hive.openBox<QuestProgressHiveModel>(
    HiveBoxNames.questProgress,
  );
  final ledgerBox = await Hive.openBox<XpTransactionHiveModel>(
    HiveBoxNames.xpTransactions,
  );

  return ProviderContainer(
    overrides: [
      questHiveBoxProvider.overrideWithValue(questBox),
      questProgressHiveBoxProvider.overrideWithValue(progressBox),
      xpTransactionHiveBoxProvider.overrideWithValue(ledgerBox),
      ...extraOverrides,
    ],
  );
}
