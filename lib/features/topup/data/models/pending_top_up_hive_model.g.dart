// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_top_up_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingTopUpHiveModelAdapter extends TypeAdapter<PendingTopUpHiveModel> {
  @override
  final int typeId = 2;

  @override
  PendingTopUpHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingTopUpHiveModel(
      beneficiaryId: fields[0] as String,
      amount: fields[1] as double,
      timestamp: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PendingTopUpHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.beneficiaryId)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingTopUpHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
