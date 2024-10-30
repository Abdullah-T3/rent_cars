// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PhotoAdapter extends TypeAdapter<Photo> {
  @override
  final int typeId = 5;

  @override
  Photo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Photo(
      url: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Photo obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
