// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestHiveModelAdapter extends TypeAdapter<QuestHiveModel> {
  @override
  final typeId = 0;

  @override
  QuestHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as String,
      difficulty: fields[4] as String,
      attributeXpWeights: (fields[5] as Map).cast<String, int>(),
      linkedIdentityStatementIds: (fields[6] as List).cast<String>(),
      progressType: fields[7] as String,
      currentProgress: (fields[8] as num).toDouble(),
      targetProgress: (fields[9] as num).toDouble(),
      deadlineUtcMicros: (fields[10] as num?)?.toInt(),
      questChainId: fields[11] as String?,
      prerequisiteQuestIds: (fields[12] as List).cast<String>(),
      state: fields[13] as String,
      failureBehavior: fields[14] as String,
      repeatabilityRule: fields[15] as String?,
      rewardXp: (fields[16] as num?)?.toInt(),
      rewardTitleId: fields[17] as String?,
      rewardAchievementId: fields[18] as String?,
      hasReward: fields[19] == null ? false : fields[19] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, QuestHiveModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.difficulty)
      ..writeByte(5)
      ..write(obj.attributeXpWeights)
      ..writeByte(6)
      ..write(obj.linkedIdentityStatementIds)
      ..writeByte(7)
      ..write(obj.progressType)
      ..writeByte(8)
      ..write(obj.currentProgress)
      ..writeByte(9)
      ..write(obj.targetProgress)
      ..writeByte(10)
      ..write(obj.deadlineUtcMicros)
      ..writeByte(11)
      ..write(obj.questChainId)
      ..writeByte(12)
      ..write(obj.prerequisiteQuestIds)
      ..writeByte(13)
      ..write(obj.state)
      ..writeByte(14)
      ..write(obj.failureBehavior)
      ..writeByte(15)
      ..write(obj.repeatabilityRule)
      ..writeByte(16)
      ..write(obj.rewardXp)
      ..writeByte(17)
      ..write(obj.rewardTitleId)
      ..writeByte(18)
      ..write(obj.rewardAchievementId)
      ..writeByte(19)
      ..write(obj.hasReward);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
