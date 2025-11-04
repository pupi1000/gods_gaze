// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 3;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      primaryLoveLanguage: fields[0] as LoveLanguage,
      stressResponse: fields[1] as StressResponse,
      magicButtonText: fields[2] as String,
      age: fields[3] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.primaryLoveLanguage)
      ..writeByte(1)
      ..write(obj.stressResponse)
      ..writeByte(2)
      ..write(obj.magicButtonText)
      ..writeByte(3)
      ..write(obj.age);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoveLanguageAdapter extends TypeAdapter<LoveLanguage> {
  @override
  final int typeId = 1;

  @override
  LoveLanguage read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LoveLanguage.words;
      case 1:
        return LoveLanguage.time;
      case 2:
        return LoveLanguage.gifts;
      case 3:
        return LoveLanguage.service;
      case 4:
        return LoveLanguage.touch;
      case 5:
        return LoveLanguage.none;
      default:
        return LoveLanguage.words;
    }
  }

  @override
  void write(BinaryWriter writer, LoveLanguage obj) {
    switch (obj) {
      case LoveLanguage.words:
        writer.writeByte(0);
        break;
      case LoveLanguage.time:
        writer.writeByte(1);
        break;
      case LoveLanguage.gifts:
        writer.writeByte(2);
        break;
      case LoveLanguage.service:
        writer.writeByte(3);
        break;
      case LoveLanguage.touch:
        writer.writeByte(4);
        break;
      case LoveLanguage.none:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoveLanguageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StressResponseAdapter extends TypeAdapter<StressResponse> {
  @override
  final int typeId = 2;

  @override
  StressResponse read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StressResponse.talk;
      case 1:
        return StressResponse.solutions;
      case 2:
        return StressResponse.distraction;
      case 3:
        return StressResponse.space;
      case 4:
        return StressResponse.none;
      default:
        return StressResponse.talk;
    }
  }

  @override
  void write(BinaryWriter writer, StressResponse obj) {
    switch (obj) {
      case StressResponse.talk:
        writer.writeByte(0);
        break;
      case StressResponse.solutions:
        writer.writeByte(1);
        break;
      case StressResponse.distraction:
        writer.writeByte(2);
        break;
      case StressResponse.space:
        writer.writeByte(3);
        break;
      case StressResponse.none:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StressResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
