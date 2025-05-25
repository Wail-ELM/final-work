// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_time_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScreenTimeEntryAdapter extends TypeAdapter<ScreenTimeEntry> {
  @override
  final int typeId = 2;

  @override
  ScreenTimeEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScreenTimeEntry(
      date: fields[0] as DateTime,
      appName: fields[1] as String,
      duration: fields[2] as Duration,
    );
  }

  @override
  void write(BinaryWriter writer, ScreenTimeEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.appName)
      ..writeByte(2)
      ..write(obj.duration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScreenTimeEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
