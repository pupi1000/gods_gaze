// lib/models/log_entry.dart
import 'package:hive/hive.dart';

part 'log_entry.g.dart';

// ... (DailyMood y LogCause no cambian) ...
@HiveType(typeId: 4) 
enum DailyMood {
  @HiveField(0)
  feliz,
  @HiveField(1)
  calmada,
  @HiveField(2)
  triste,
  @HiveField(3)
  irritable,
  @HiveField(4)
  cansada,
}
@HiveType(typeId: 5)
enum LogCause {
  @HiveField(0)
  ciclo,
  @HiveField(1)
  vida,
  @HiveField(2)
  ambos,
  @HiveField(3)
  noseguro,
}

// --- ¡CAMBIO AQUÍ! Añadimos 'noseguro' ---
@HiveType(typeId: 7)
enum DailyEnergy {
  @HiveField(0)
  baja,
  @HiveField(1)
  media,
  @HiveField(2)
  alta,
  @HiveField(3) // <-- NUEVO
  noseguro,
}

// --- ¡CAMBIO AQUÍ! Añadimos 'noseguro' ---
@HiveType(typeId: 8)
enum SleepQuality {
  @HiveField(0)
  mala,
  @HiveField(1)
  regular,
  @HiveField(2)
  buena,
  @HiveField(3) // <-- NUEVO
  noseguro,
}

@HiveType(typeId: 6) 
class LogEntry extends HiveObject { 
  @HiveField(0)
  DateTime date; // <-- Cambiado a no-final para poder editar

  @HiveField(1)
  DailyMood mood; // <-- Cambiado a no-final

  @HiveField(2)
  LogCause cause; // <-- Cambiado a no-final
  
  @HiveField(3)
  String note; // <-- Cambiado a no-final

  @HiveField(4)
  DailyEnergy energy; // <-- Cambiado a no-final

  @HiveField(5)
  SleepQuality sleep; // <-- Cambiado a no-final

  LogEntry({
    required this.date,
    required this.mood,
    required this.cause,
    required this.note,
    required this.energy,
    required this.sleep,
  });
}