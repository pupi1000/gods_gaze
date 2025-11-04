// lib/models/app_settings.dart
import 'package:hive/hive.dart';

// 1. Esta línea es NUEVA. Le dice a Dart que espere un archivo generado.
part 'app_settings.g.dart';

// 2. @HiveType le da un ID único a tu clase
@HiveType(typeId: 0)
class AppSettings {
  
  // 3. @HiveField le da un ID único a cada campo
  @HiveField(0)
  final DateTime lastPeriodDate;

  @HiveField(1)
  final int cycleDuration;

  AppSettings({
    required this.lastPeriodDate,
    required this.cycleDuration,
  });
}