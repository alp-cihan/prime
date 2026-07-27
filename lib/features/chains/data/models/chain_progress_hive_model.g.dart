// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain_progress_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChainProgressHiveModelAdapter
    extends TypeAdapter<ChainProgressHiveModel> {
  @override
  final typeId = 4;

  @override
  ChainProgressHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChainProgressHiveModel(
      chainId: fields[0] as String,
      completedStageCount: (fields[1] as num).toInt(),
      completedAtUtcMicros: (fields[2] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, ChainProgressHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.chainId)
      ..writeByte(1)
      ..write(obj.completedStageCount)
      ..writeByte(2)
      ..write(obj.completedAtUtcMicros);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChainProgressHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
