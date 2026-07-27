import 'package:hive_ce/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../bootstrap/hive_bootstrap.dart' as bootstrap;
import '../../features/achievements/data/models/achievement_unlock_hive_model.dart';
import '../../features/chains/data/models/chain_progress_hive_model.dart';
import '../../features/quests/data/models/quest_hive_model.dart';
import '../../features/quests/data/models/quest_progress_hive_model.dart';
import '../../features/xp_ledger/data/models/xp_transaction_hive_model.dart';

part 'persistence_providers.g.dart';

/// Exposes the three Hive boxes opened once by `bootstrapHive()` at app
/// startup. These providers never open, close, or otherwise own the box
/// lifecycle themselves — they only read the already-open box — so
/// disposing a provider (or a test container) never closes a box owned by
/// app bootstrap. `keepAlive: true` because each box is a singleton for the
/// app's lifetime; nothing about a box should be recreated mid-session.
///
/// Tests override these three providers directly with real temporary Hive
/// boxes (see test/support/hive_test_support.dart) rather than going
/// through `bootstrapHive()`, which requires the Flutter plugin channel.
@Riverpod(keepAlive: true)
Box<QuestHiveModel> questHiveBox(Ref ref) => bootstrap.questBox();

@Riverpod(keepAlive: true)
Box<QuestProgressHiveModel> questProgressHiveBox(Ref ref) =>
    bootstrap.questProgressBox();

@Riverpod(keepAlive: true)
Box<XpTransactionHiveModel> xpTransactionHiveBox(Ref ref) =>
    bootstrap.xpTransactionBox();

@Riverpod(keepAlive: true)
Box<AchievementUnlockHiveModel> achievementUnlockHiveBox(Ref ref) =>
    bootstrap.achievementUnlockBox();

@Riverpod(keepAlive: true)
Box<ChainProgressHiveModel> chainProgressHiveBox(Ref ref) =>
    bootstrap.chainProgressBox();
