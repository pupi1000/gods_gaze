// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LogEntryAdapter extends TypeAdapter<LogEntry> {
  @override
  final int typeId = 6;

  @override
  LogEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LogEntry(
      date: fields[0] as DateTime,
      mood: fields[1] as DailyMood,
      cause: fields[2] as LogCause,
      note: fields[3] as String,
      energy: fields[4] as DailyEnergy,
      sleep: fields[5] as SleepQuality,
      cycleDay: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LogEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.mood)
      ..writeByte(2)
      ..write(obj.cause)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.energy)
      ..writeByte(5)
      ..write(obj.sleep)
      ..writeByte(6)
      ..write(obj.cycleDay);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailyMoodAdapter extends TypeAdapter<DailyMood> {
  @override
  final int typeId = 4;

  @override
  DailyMood read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DailyMood.feliz;
      case 1:
        return DailyMood.calmada;
      case 2:
        return DailyMood.triste;
      case 3:
        return DailyMood.irritable;
      case 4:
        return DailyMood.cansada;
      default:
        return DailyMood.feliz;
    }
  }

  @override
  void write(BinaryWriter writer, DailyMood obj) {
    switch (obj) {
      case DailyMood.feliz:
        writer.writeByte(0);
        break;
      case DailyMood.calmada:
        writer.writeByte(1);
        break;
      case DailyMood.triste:
        writer.writeByte(2);
        break;
      case DailyMood.irritable:
        writer.writeByte(3);
        break;
      case DailyMood.cansada:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyMoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LogCauseAdapter extends TypeAdapter<LogCause> {
  @override
  final int typeId = 5;

  @override
  LogCause read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LogCause.ciclo;
      case 1:
        return LogCause.vida;
      case 2:
        return LogCause.ambos;
      case 3:
        return LogCause.noseguro;
      default:
        return LogCause.ciclo;
    }
  }

  @override
  void write(BinaryWriter writer, LogCause obj) {
    switch (obj) {
      case LogCause.ciclo:
        writer.writeByte(0);
        break;
      case LogCause.vida:
        writer.writeByte(1);
        break;
      case LogCause.ambos:
        writer.writeByte(2);
        break;
      case LogCause.noseguro:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogCauseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailyEnergyAdapter extends TypeAdapter<DailyEnergy> {
  @override
  final int typeId = 7;

  @override
  DailyEnergy read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DailyEnergy.baja;
      case 1:
        return DailyEnergy.media;
      case 2:
        return DailyEnergy.alta;
      case 3:
        return DailyEnergy.noseguro;
      default:
        return DailyEnergy.baja;
    }
  }

  @override
  void write(BinaryWriter writer, DailyEnergy obj) {
    switch (obj) {
      case DailyEnergy.baja:
        writer.writeByte(0);
        break;
      case DailyEnergy.media:
        writer.writeByte(1);
        break;
      case DailyEnergy.alta:
        writer.writeByte(2);
        break;
      case DailyEnergy.noseguro:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyEnergyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SleepQualityAdapter extends TypeAdapter<SleepQuality> {
  @override
  final int typeId = 8;

  @override
  SleepQuality read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SleepQuality.mala;
      case 1:
        return SleepQuality.regular;
      case 2:
        return SleepQuality.buena;
      case 3:
        return SleepQuality.noseguro;
      default:
        return SleepQuality.mala;
    }
  }

  @override
  void write(BinaryWriter writer, SleepQuality obj) {
    switch (obj) {
      case SleepQuality.mala:
        writer.writeByte(0);
        break;
      case SleepQuality.regular:
        writer.writeByte(1);
        break;
      case SleepQuality.buena:
        writer.writeByte(2);
        break;
      case SleepQuality.noseguro:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SleepQualityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
