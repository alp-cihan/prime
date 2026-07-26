// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_progress_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestProgressHiveModelAdapter
    extends TypeAdapter<QuestProgressHiveModel> {
  @override
  final typeId = 1;

  @override
  QuestProgressHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestProgressHiveModel(
      questId: fields[0] as String,
      dateUtcMicros: (fields[1] as num).toInt(),
      progressValue: (fields[2] as num).toDouble(),
      isComplete: fields[3] as bool,
      notes: fields[4] as String?,
      qualityRating: (fields[5] as num?)?.toInt(),
      timeSpentMicros: (fields[6] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, QuestProgressHiveModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.questId)
      ..writeByte(1)
      ..write(obj.dateUtcMicros)
      ..writeByte(2)
      ..write(obj.progressValue)
      ..writeByte(3)
      ..write(obj.isComplete)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.qualityRating)
      ..writeByte(6)
      ..write(obj.timeSpentMicros);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestProgressHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
