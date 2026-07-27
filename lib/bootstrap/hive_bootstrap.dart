import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../core/persistence/hive_box_names.dart';
import '../core/persistence/hive_type_ids.dart';
import '../features/achievements/data/models/achievement_unlock_hive_model.dart';
import '../features/chains/data/models/chain_progress_hive_model.dart';
import '../features/quests/data/models/quest_hive_model.dart';
import '../features/quests/data/models/quest_progress_hive_model.dart';
import '../features/xp_ledger/data/models/xp_transaction_hive_model.dart';
import '../hive_registrar.g.dart';

/// Initializes the Hive CE storage engine, registers all generated
/// adapters, and opens the three Phase 3 boxes. Safe to call more than
/// once — [Hive.registerAdapters] throws if called twice unguarded (it
/// raises on a duplicate typeId), so registration is skipped once already
/// done, and each box open is guarded by [Hive.isBoxOpen].
Future<void> bootstrapHive() async {
  await Hive.initFlutter();
  _registerAdaptersIfNeeded();
  await _openBoxes();
}

void _registerAdaptersIfNeeded() {
  if (Hive.isAdapterRegistered(HiveTypeIds.quest)) return;
  Hive.registerAdapters();
}

Future<void> _openBoxes() async {
  if (!Hive.isBoxOpen(HiveBoxNames.quests)) {
    await Hive.openBox<QuestHiveModel>(HiveBoxNames.quests);
  }
  if (!Hive.isBoxOpen(HiveBoxNames.questProgress)) {
    await Hive.openBox<QuestProgressHiveModel>(HiveBoxNames.questProgress);
  }
  if (!Hive.isBoxOpen(HiveBoxNames.xpTransactions)) {
    await Hive.openBox<XpTransactionHiveModel>(HiveBoxNames.xpTransactions);
  }
  if (!Hive.isBoxOpen(HiveBoxNames.achievementUnlocks)) {
    await Hive.openBox<AchievementUnlockHiveModel>(
      HiveBoxNames.achievementUnlocks,
    );
  }
  if (!Hive.isBoxOpen(HiveBoxNames.chainProgress)) {
    await Hive.openBox<ChainProgressHiveModel>(HiveBoxNames.chainProgress);
  }
}

/// Accessors for the already-opened boxes — call only after [bootstrapHive].
Box<QuestHiveModel> questBox() => Hive.box<QuestHiveModel>(HiveBoxNames.quests);

Box<QuestProgressHiveModel> questProgressBox() =>
    Hive.box<QuestProgressHiveModel>(HiveBoxNames.questProgress);

Box<XpTransactionHiveModel> xpTransactionBox() =>
    Hive.box<XpTransactionHiveModel>(HiveBoxNames.xpTransactions);

Box<AchievementUnlockHiveModel> achievementUnlockBox() =>
    Hive.box<AchievementUnlockHiveModel>(HiveBoxNames.achievementUnlocks);

Box<ChainProgressHiveModel> chainProgressBox() =>
    Hive.box<ChainProgressHiveModel>(HiveBoxNames.chainProgress);
