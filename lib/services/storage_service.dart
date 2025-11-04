// lib/services/storage_service.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
// Usamos rutas relativas (como en la última corrección)
import '../models/app_settings.dart';
import '../models/log_entry.dart';
import '../models/user_profile.dart';

const String _kSettingsBox = 'settingsBox';
const String _kProfileBox = 'profileBox';
const String _kLogBox = 'logBox';

class StorageService with ChangeNotifier {
  late Box<AppSettings> _settingsBox;
  late Box<UserProfile> _profileBox;
  late Box<LogEntry> _logBox;

  // --- Getters ---
  
  AppSettings? get settings {
    return _settingsBox.get('default');
  }

  UserProfile? get profile {
    return _profileBox.get('default');
  }

  List<LogEntry> get logHistory {
    return _logBox.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  // --- Constructor ---

  Future<void> loadAllDataFromHive() async {
    _settingsBox = await Hive.openBox<AppSettings>(_kSettingsBox);
    _profileBox = await Hive.openBox<UserProfile>(_kProfileBox);
    _logBox = await Hive.openBox<LogEntry>(_kLogBox);
    
    notifyListeners();
  }

  // --- Lógica de Guardado (Pilar 1 y 3) ---

  Future<void> saveSettings(DateTime lastPeriodDate, int cycleDuration) async {
    final newSettings = AppSettings(
      lastPeriodDate: lastPeriodDate,
      cycleDuration: cycleDuration,
    );
    await _settingsBox.put('default', newSettings);
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _profileBox.put('default', profile);
    notifyListeners();
  }

  // --- ¡NUEVA FUNCIÓN! (Pilar 2) ---
  // (¡¡YA NO ESTÁ DUPLICADA!!)
  Future<void> saveLogEntry(LogEntry entry) async {
    await _logBox.add(entry);
    notifyListeners(); // Avisamos a la app que hay un nuevo log
  }

  // --- ¡¡NUEVA FUNCIÓN DE BORRADO (CRUD)!! ---
  Future<void> deleteLogEntry(LogEntry entry) async {
    // Como LogEntry extiende HiveObject, podemos llamar a .delete()
    await entry.delete();
    notifyListeners(); // Avisamos a la app que un log desapareció
  }
  // --- FIN DE LA NUEVA FUNCIÓN ---
}