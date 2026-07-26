// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_transaction_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class XpTransactionHiveModelAdapter
    extends TypeAdapter<XpTransactionHiveModel> {
  @override
  final typeId = 2;

  @override
  XpTransactionHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return XpTransactionHiveModel(
      id: fields[0] as String,
      sourceType: fields[1] as String,
      sourceId: fields[2] as String,
      attribute: fields[3] as String,
      baseXp: (fields[4] as num).toInt(),
      modifiersApplied: (fields[5] as Map).cast<String, double>(),
      finalXp: (fields[6] as num).toInt(),
      createdAtUtcMicros: (fields[7] as num).toInt(),
      idempotencyKey: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, XpTransactionHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sourceType)
      ..writeByte(2)
      ..write(obj.sourceId)
      ..writeByte(3)
      ..write(obj.attribute)
      ..writeByte(4)
      ..write(obj.baseXp)
      ..writeByte(5)
      ..write(obj.modifiersApplied)
      ..writeByte(6)
      ..write(obj.finalXp)
      ..writeByte(7)
      ..write(obj.createdAtUtcMicros)
      ..writeByte(8)
      ..write(obj.idempotencyKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is XpTransactionHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
