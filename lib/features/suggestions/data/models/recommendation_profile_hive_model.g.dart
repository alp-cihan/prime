// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_profile_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecommendationProfileHiveModelAdapter
    extends TypeAdapter<RecommendationProfileHiveModel> {
  @override
  final typeId = 5;

  @override
  RecommendationProfileHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecommendationProfileHiveModel(
      lifeStage: fields[0] as String,
      goals: (fields[1] as List).cast<String>(),
      availableTime: fields[2] as String,
      intensity: fields[3] as String,
      isPersonalized: fields[4] as bool,
      acceptedSuggestionIds: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, RecommendationProfileHiveModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.lifeStage)
      ..writeByte(1)
      ..write(obj.goals)
      ..writeByte(2)
      ..write(obj.availableTime)
      ..writeByte(3)
      ..write(obj.intensity)
      ..writeByte(4)
      ..write(obj.isPersonalized)
      ..writeByte(5)
      ..write(obj.acceptedSuggestionIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecommendationProfileHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
