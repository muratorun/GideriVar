// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 0;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      language: fields[0] as String,
      useOnlineLocationService: fields[1] as bool,
      isDarkMode: fields[2] as bool,
      lastSelectedCountry: fields[3] as String?,
      lastSelectedCity: fields[4] as String?,
      notificationsEnabled: fields[5] as bool,
      soundEnabled: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.language)
      ..writeByte(1)
      ..write(obj.useOnlineLocationService)
      ..writeByte(2)
      ..write(obj.isDarkMode)
      ..writeByte(3)
      ..write(obj.lastSelectedCountry)
      ..writeByte(4)
      ..write(obj.lastSelectedCity)
      ..writeByte(5)
      ..write(obj.notificationsEnabled)
      ..writeByte(6)
      ..write(obj.soundEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
