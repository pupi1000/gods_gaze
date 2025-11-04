// lib/models/user_profile.dart
import 'package:hive/hive.dart'; // <--- ¡¡ESTA LÍNEA ES LA QUE FALTA!!

part 'user_profile.g.dart'; 

// --- Enums ---
@HiveType(typeId: 1)
enum LoveLanguage {
  @HiveField(0)
  words,
  @HiveField(1)
  time,
  @HiveField(2)
  gifts,
  @HiveField(3)
  service,
  @HiveField(4)
  touch,
  @HiveField(5)
  none,
}

@HiveType(typeId: 2)
enum StressResponse {
  @HiveField(0)
  talk,
  @HiveField(1)
  solutions,
  @HiveField(2)
  distraction,
  @HiveField(3)
  space,
  @HiveField(4)
  none,
}

// --- Modelo Principal ---
@HiveType(typeId: 3)
class UserProfile {
  @HiveField(0)
  final LoveLanguage primaryLoveLanguage;

  @HiveField(1)
  final StressResponse stressResponse;

  @HiveField(2)
  final String magicButtonText;

  @HiveField(3)
  final int? age; // int? (nullable)

  UserProfile({
    this.primaryLoveLanguage = LoveLanguage.none,
    this.stressResponse = StressResponse.none,
    this.magicButtonText = '',
    this.age,
  });
}