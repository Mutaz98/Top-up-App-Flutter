// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beneficiary_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BeneficiaryHiveModelAdapter extends TypeAdapter<BeneficiaryHiveModel> {
  @override
  final int typeId = 1;

  @override
  BeneficiaryHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BeneficiaryHiveModel(
      id: fields[0] as String,
      nickname: fields[1] as String,
      phoneNumber: fields[2] as String,
      monthlyTopUpTotal: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, BeneficiaryHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nickname)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.monthlyTopUpTotal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BeneficiaryHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
