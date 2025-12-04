// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CallEntryAdapter extends TypeAdapter<CallEntry> {
  @override
  final int typeId = 0;

  @override
  CallEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CallEntry(
      number: fields[0] as String,
      isCalled: fields[1] as bool,
      shouldTryLater: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CallEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.isCalled)
      ..writeByte(2)
      ..write(obj.shouldTryLater);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CallEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
