// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_unlock_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementUnlockHiveModelAdapter
    extends TypeAdapter<AchievementUnlockHiveModel> {
  @override
  final typeId = 3;

  @override
  AchievementUnlockHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AchievementUnlockHiveModel(
      achievementId: fields[0] as String,
      unlockedAtUtcMicros: (fields[1] as num).toInt(),
      rewardIdempotencyKey: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AchievementUnlockHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.achievementId)
      ..writeByte(1)
      ..write(obj.unlockedAtUtcMicros)
      ..writeByte(2)
      ..write(obj.rewardIdempotencyKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementUnlockHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
