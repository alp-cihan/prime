import '../../../../core/domain/attribute_type.dart';
import '../../../xp_ledger/domain/entities/xp_transaction.dart';
import '../../domain/entities/quest_progress.dart';

/// Outcome of a successful [CompleteQuestUseCase] run.
class CompleteQuestResult {
  final QuestProgress progress;
  final List<XpTransaction> transactions;
  final int totalXpAwarded;
  final Map<AttributeType, int> xpByAttribute;
  final bool firstCompletionBonusApplied;
  final bool dailyCapLimited;

  const CompleteQuestResult({
    required this.progress,
    required this.transactions,
    required this.totalXpAwarded,
    required this.xpByAttribute,
    required this.firstCompletionBonusApplied,
    required this.dailyCapLimited,
  });
}
